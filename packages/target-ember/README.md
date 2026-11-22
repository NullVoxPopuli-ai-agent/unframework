# @unframework.dev/target-ember

The Ember 7.4 target of the Unframework compiler: one `.gts` file per component, in Glimmer's
strict mode. The target is opt-in (`targets: ["ember"]`), and it emits the static and props subset
of components so far ([#236](https://github.com/uxfront-com/unframework/issues/236)). A module that
needs anything else has no Ember output: its capability cells are unsupported, as errors, and the
compiler reports UF4001 at the first use.

## The module

In order: the imports from `@glimmer/component`, `@glimmer/tracking` and `@ember/*`, and the
pass-through imports (ADR-0064); the type declarations the component reaches, copied as written
(ADR-0067, ADR-0068); the signature; the component; the inline helpers it calls.

- **The signature.** `export interface CardSignature { Args: CardProps; Element: … }`. `Args` is
  the props annotation as written. `Element` is the root element's interface, for a component with
  one root element, which takes the caller's attributes with `...attributes`.
- **Template-only.** A component with no member of its own is a `TOC<CardSignature>` constant whose
  template reads its props as `{{@title}}`.
- **A class.** Any other component is a `@glimmer/component` class. A prop with a default is a
  getter, which an absent or `undefined` argument sends to the default. The setup's `ref` is a
  `@tracked` field, a `computed` a getter, a `const` a `readonly` field and a function an arrow
  field, in source order.
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
  `button` imported), so such a name takes another (`button_1`).
- **Text.** `{{` is written `\{{`. Inside a `<pre>`, a line feed that starts a text after a
  mustache is `&#10;`, since Glimmer's tokenizer drops it as HTML drops the one after the start tag.

## Capabilities

`bound-attribute` and `attribute-spread` go through `enumeratedValue`, which writes the boolean of
an ARIA or enumerated attribute as its name, as Vue does, where Glimmer writes `true` as an empty
attribute and leaves `false` out. `class-binding` goes through `classNames`, and `style-binding`
through `styleText`, which marks the style safe with `htmlSafe`. `contextual-root` is native: a
Glimmer component has no host element. Every other capability but the static and props subset is
unsupported for now (`src/index.ts`).

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
  object that a rerender updates. `renderComponent` reads the argument names once, so a rerender
  that adds a name renders the component again.
- **`…/toolchain/server`**: renders with `renderComponent` into a simple-dom document, without a
  DOM, and serialises it.
