# @unframework.dev/target-ember

The Ember 7.4 target of the Unframework compiler: one `.gts` file per component, in Glimmer's
strict mode. The target is opt-in (`targets: ["ember"]`), and it emits the static and props subset
of components, with listeners, emits, template refs, watchers and lifecycle hooks, so far
([#236](https://github.com/uxfront-com/unframework/issues/236)). A module that
needs anything else has no Ember output: its capability cells are unsupported, as errors, and the
compiler reports UF4001 at the first use.

## The module

In order: the imports from `@glimmer/component`, `@glimmer/tracking` and `@ember/*`, the
pass-through imports (ADR-0064) and the values it reads of its `.ts` modules (ADR-0070); the type
declarations the component reaches, copied as written (ADR-0067, ADR-0068); the module's constants
it reads; the signature; the component; the inline helpers it calls.

- **The signature.** `export interface CardSignature { Args: CardProps & CardEvents; Element: … }`.
  `Args` is the props annotation as written, and the events' interface, `CardEvents`, whose
  members are optional arguments, `onChange` for `change`, that take the event's payload. `Element` is the root element's interface, for a component with
  one root element, which takes the caller's attributes with `...attributes`.
- **Template-only.** A component with no member of its own is a `TOC<CardSignature>` constant whose
  template reads its props as `{{@title}}`.
- **A class.** Any other component is a `@glimmer/component` class. A prop with a default is a
  getter, which an absent or `undefined` argument sends to the default. The setup's functions are
  arrow fields, first, as the source's declarations are hoisted. Then, in source order, a `ref`
  and a template ref are `@tracked` fields, a `computed` a getter and a `const` a `readonly` field.
- **Listeners and emits.** `{{on "click" this.save}}`, with `capture=true`, `once=true` and
  `passive=true` as named arguments. An inline handler is an arrow field (`this.listener1`), or one
  that takes the row variables it reads (`(this.listener1 item)`). It tests again the conditions of
  the branches around it that narrow what it reads. `emit("change", value)` calls
  `this.args.onChange?.(value)`.
- **Template refs.** An inline modifier, `{{templateRef this "input"}}`, sets the member to its
  element once it is rendered, and to `null` once it is gone.
- **Watchers and hooks.** Glimmer has no effects, so the template calls them. It calls each
  watcher's `flush` before anything else: the callback runs right after the render that sees a
  change of a source, or once that render settles for `flush: "post"`. A state with a
  `watchEffect` beside it is `@tracked({ equals: Object.is })`, so a write of the value it holds
  runs nothing, as on Vue. It calls each `watchEffect`'s
  `flush` after everything else, from the first render that settles in the browser. And it calls
  `onMounted` last: the `onMounted` hooks run once the first render settles, and the `onUnmounted`
  hooks are registered as destructors then. A component destroyed first, as a server render is,
  runs none of them. Cleanups run before the next run and when the component is destroyed.
  Effects are an anti-pattern in Ember, as in every framework: a source that derives the value,
  or does the work in the handler that causes the change, compiles to plainer Ember. These
  helpers exist so that a source with `watch` or `watchEffect` still compiles.
- **Expressions.** A Glimmer template reads paths, literals and helper calls, never JavaScript. So
  a path (`@user.name`, `this.total`, `item.label`) and a literal stay in the template, and any
  other expression becomes a member: a getter (`{{this.value1}}`), or an arrow field the template
  calls with the row variables it reads (`{{this.value2 item}}`), its parameters typed from the
  list's source (`NonNullable<this["args"]["items"]>[number]`). A member reads its expression under
  the conditions of the branches around it that read what it reads, since a getter is no branch
  TypeScript narrows in. A path under a condition that is no path is a member too.
- **Control flow.** `{{#if}}`, `{{else if}}` and `{{else}}`, and `{{#each … key="…" as |item|}}`,
  keyed by the item's path, `@index` or `@identity`.
- **Names.** Glimmer reads a tag named like a name in scope as that component (`<button>` with
  `button` imported), so such a name takes another (`button_1`), as does a name that is a keyword
  of the template (`each_1`).
- **Text.** `{{` is written `\{{`. Inside a `<pre>`, a line feed that starts a text after a
  mustache is `&#10;`, since Glimmer's tokenizer drops it as HTML drops the one after the start tag.

## Capabilities

`bound-attribute` and `attribute-spread` go through `enumeratedValue`, which writes the boolean of
an ARIA or enumerated attribute as its name, as Vue does, where Glimmer writes `true` as an empty
attribute and leaves `false` out. `class-binding` goes through `classNames`, and `style-binding`
through `styleText`, which marks the style safe with `htmlSafe`. `contextual-root` is native: a
Glimmer component has no host element. `interactivity` and the listeners' options and semantics
are native: `{{on}}` calls `addEventListener` on its element. `use-id` is native: `useId()` is
`uf-id-` and `uniqueId()` from `@ember/helper`. `next-tick` is native: `nextTick()` is
`renderSettled()` from `@ember/renderer`, which resolves once the pending render has run, as
Vue's resolves once its pending flush has. `keyed-identity` and `listbox` follow from Glimmer.
Late props, models, directives,
composition, composables, scoped styles and hydration are unsupported for now (`src/index.ts`).

## The toolchain

For tests and tooling (the target's main entry never loads it):

- **`@unframework.dev/target-ember/toolchain`**: a Vite plugin, `unframework:ember`, that runs a
  `.gts` module through content-tag, then Babel with `babel-plugin-ember-template-compilation`
  and the template compiler of the project's `ember-source`, and `decorator-transforms`. It
  resolves `@ember/*` and `@glimmer/tracking` to `ember-source`'s own modules. The checks:
  - L3 compiles each file the same way and reports what throws.
  - L4 runs Glint (`ember-tsc`, TypeScript 6) from `tests/toolchains/ember`.
  - L5 runs ESLint with eslint-plugin-ember over the `.gts` files, which oxlint does not parse,
    and oxlint's baseline over a `.ts` module beside them.
- **`…/toolchain/client`**: mounts with `renderComponent` (RFC 1099), its arguments a tracked
  object that a rerender updates, with the test's listeners as `onChange` arguments. `renderComponent` reads the argument names once, so a rerender
  that adds a name renders the component again.
- **`…/toolchain/server`**: renders with `renderComponent` into a simple-dom document, without a
  DOM, and serialises it.
