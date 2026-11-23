import { CAPABILITY_NAMES, defineTarget, requiredCapabilities } from "@unframework.dev/codegen";
import type {
  Capabilities,
  CapabilityCell,
  CapabilityName,
  EmitContext,
  OutputFile,
  Target,
} from "@unframework.dev/codegen";
import type { Span, UfComponent, UfModule } from "@unframework.dev/ir";

import { emitComponent } from "./component.ts";
import { emitDirective } from "./directive.ts";

/** A capability the Ember target does not emit yet, which its cases skip with this reason. */
function notYet(reason: string): CapabilityCell {
  return {
    support: "unsupported",
    code: "UF4001",
    severity: "error",
    reason: `${reason} See uxfront-com/unframework#236.`,
  };
}

const NATIVE: CapabilityCell = { support: "native" };

/**
 * The cells the target leaves unsupported by design, as warnings: the component compiles, and
 * only what the cell names behaves differently.
 */
const BY_DESIGN: Partial<Record<CapabilityName, CapabilityCell>> = {
  "late-prop": {
    support: "unsupported",
    code: "UF4001",
    severity: "warning",
    reason:
      "An Ember parent names each argument in its template, so it never adds one after mount, and the target does not make a component follow one that appears later: a parent that would add an argument late passes it from the start, `undefined` while it has no value.",
  },
};

/** The cells whose feature the output builds with an inline helper, by capability. */
const EMULATED: Partial<Record<CapabilityName, CapabilityCell>> = {
  // Glimmer writes `true` as an empty attribute and leaves `false` out, where Vue writes an
  // ARIA or enumerated attribute's boolean as its name, `aria-expanded="false"`.
  "bound-attribute": {
    support: "emulated",
    helper: "enumeratedValue",
    note: 'Glimmer writes `true` as an empty attribute and leaves `false` out, where Vue writes the boolean of an ARIA attribute and of contenteditable, draggable and spellcheck as its name. So such a value goes through an inline helper, enumeratedValue, that writes "true" or "false" and passes any other value as it is.',
  },
  "attribute-spread": {
    support: "emulated",
    helper: "enumeratedValue",
    note: "A spread is written out per key, and an ARIA or enumerated key goes through enumeratedValue, as a bound one does, so a boolean is written as its name.",
  },
  // A Glimmer `class` is one string.
  "class-binding": {
    support: "emulated",
    helper: "classNames",
    note: "A Glimmer `class` is one string, so an inline helper, classNames, joins the static names, toggles and dynamic parts, and reads an array's entries and an object's keys as Vue's normalizeClass does.",
  },
  directive: {
    support: "emulated",
    helper: "queueHook",
    note: "A directive is a modifier on Ember's own manager. Glimmer installs a parent's modifier before its children's, so each hook goes through an inline helper, queueHook, that runs them in Vue's order, and no hook runs on the server.",
  },
  "dynamic-component": {
    support: "emulated",
    helper: "{{#if}}",
    note: "Glimmer has no `<component is>` over a tag, so each candidate is a branch of an `{{#if}}`: a tag where the choice is its name, a component where it is the component.",
  },
  expose: {
    support: "emulated",
    helper: "componentRef",
    note: "A Glimmer component has no instance a parent can hold, so a component ref is the child's `@ref` argument, a callback from an inline helper, componentRef: the child calls it with what `defineExpose` exposes once it has rendered, and with `null` once it is gone.",
  },
  transition: {
    support: "emulated",
    helper: "Transition",
    note: "Glimmer removes an element once its `{{#if}}` turns false, so a transition renders its elements from a list, an inline helper's `Transition.entries`: the element of the branch its condition shows, and each one still leaving, until its leave ends. An inline modifier, transitionClasses, runs Vue's classes of each phase on the element, in the browser only.",
  },
  fallthrough: {
    support: "emulated",
    helper: "fallthroughStyle",
    note: "A caller's `class` reaches the root through `...attributes`, where Glimmer joins it with the root's own. Glimmer lets a caller's `style` attribute replace the root's own, so a `style` is the `@style` argument, which an inline helper, fallthroughStyle, merges into the root's declarations as Vue does.",
  },
  "reactive-context": {
    support: "emulated",
    helper: "refOf",
    note: "A provided state is its ref as descendants read it: an inline helper, refOf, makes an object whose `value` getter reads the tracked field, so a descendant renders each change.",
  },
  // A Glimmer `style` is one string, which Ember asks to be marked safe.
  interactivity: {
    support: "emulated",
    helper: "Watcher",
    note: "State, derived values, listeners and template refs are tracked fields, getters, `{{on}}` and an inline modifier. Glimmer has no effects, so a watcher and a watchEffect go through inline helpers, Watcher and Effect, that the template calls before and after its content: a watcher calls back right after the render that sees a change, with Vue's previous value, change test and cleanup timing, and an effect runs once the render settles. The lifecycle hooks run once the first render settles, and never on the server.",
  },
  "two-way-binding": {
    support: "emulated",
    helper: "toggle",
    note: "A `v-model` is the control's property and a listener that writes it back, as Vue's directives bind each control: `value` and `input` for a text field, `checked` and `change` for a checkbox, an option's `selected` and `change` for a `<select>`.",
  },
  "model-array": {
    support: "emulated",
    helper: "toggle",
    note: "A checkbox group's array goes through an inline helper, `toggle`, as Vue's `vModelCheckbox` does, and a `<select multiple>` writes its selected options' values.",
  },
  "model-modifiers": {
    support: "emulated",
    helper: "modelText",
    note: "A `v-model`'s modifiers and a number control's cast follow Vue's `vModelText` through an inline modifier, `modelText`.",
  },
  "style-binding": {
    support: "emulated",
    helper: "styleText",
    note: "A Glimmer `style` is one string, so an inline helper, styleText, writes the declarations whose value is present and marks the string safe with htmlSafe, as Ember asks of a bound style.",
  },
};

/**
 * What the Ember target emits so far: the static and props subset of M1, with listeners, template
 * refs, watchers and hooks (`interactivity`). Each other cell is
 * unsupported with an error, so its cases have no Ember output and skip (`ufNoOutput`).
 */
const SUPPORTED: ReadonlySet<CapabilityName> = new Set<CapabilityName>([
  "element",
  "text",
  "static-attribute",
  // A Glimmer component has no host element: its root is the parent's child.
  "contextual-root",
  "props",
  "interpolation",
  "conditional",
  "list",
  "fragment",
  "bound-attribute",
  "class-binding",
  "style-binding",
  "attribute-spread",
  "raw-html",
  "svg",
  // Ember has no context API yet: RFC 1200 (emberjs/rfcs#1200) proposes `createContext`, with
  // draft implementations in emberjs/ember.js#21450 and, on the dynamic scope, #21789. Until one
  // lands, the output follows ember-primitives' dom-context inline: a provider's text node in its
  // root, which `inject` finds by walking up the DOM. A provided state is its ref, `{ value }`.
  "context",
  "reactive-context",
  // `{{on}}` adds the listener to its element, with `addEventListener`'s options, and the
  // handler runs as the event is dispatched.
  "interactivity",
  "event-capture",
  "event-once",
  "event-passive",
  "event-semantics",
  "conditional-event-control",
  // A directive is a modifier on Ember's own manager (`directive.ts`).
  "directive",
  "dynamic-component",
  // `uniqueId` from `@ember/helper`, once per `useId`.
  "use-id",
  // `renderSettled` from `@ember/renderer`, which resolves once the pending render has run.
  "next-tick",
  // `{{#each}}` keeps a keyed row's element, and a `<select>`'s `size` is set when the element
  // opens, before its options.
  "keyed-identity",
  "listbox",
  // The module imports the sheet `compile()` scopes, and each element carries its attribute.
  "scoped-styles",
  "sheet-order",
  "two-way-binding",
  "model-array",
  "model-modifiers",
  // A child is its output's component, which the template's lexical scope holds.
  "component",
  "component-event",
  // Slots are blocks: `{{yield to="header"}}`, `<:header>`, and `(has-block "header")`.
  "default-slot",
  "named-slot",
  "scoped-slot",
  "slot-fallback",
  "default-slot-presence",
  // A parent's `data-uf-…` attribute on a child's tag reaches the child's root through
  // `...attributes`.
  "child-root-scope",
  // A fill is the parent's own markup, so its elements carry the parent's attribute.
  "slotted-styles",
  "fallthrough",
  "expose",
  // A model is the child's argument and an `@onUpdateValue` callback, as Ember passes actions.
  "model",
  // `{{#in-element}}` appends a teleport's content to its target, in the browser only.
  "teleport",
  "transition",
]);

/** The capabilities each part of the target that is not built yet holds. */
const NOT_YET: readonly { reason: string; names: readonly CapabilityName[] }[] = [
  {
    reason: "Slot forwarding, generic components and async setup are not emitted yet.",
    names: ["slot-forwarding", "generic-components", "generic-slot-props", "async-setup"],
  },
  {
    reason: "Composables are not emitted yet.",
    names: ["composables", "composable-effect-order"],
  },
  {
    reason: "The toolchain does not rehydrate a server render yet.",
    names: ["hydration"],
  },
];

/** Why a capability is not emitted yet. */
function reasonFor(name: CapabilityName): string {
  const part = NOT_YET.find((each) => each.names.includes(name));
  if (!part) throw new Error(`The Ember target declares no cell for \`${name}\`.`);
  return part.reason;
}

const CAPABILITIES = Object.fromEntries(
  CAPABILITY_NAMES.map((name) => [
    name,
    BY_DESIGN[name] ?? EMULATED[name] ?? (SUPPORTED.has(name) ? NATIVE : notYet(reasonFor(name))),
  ]),
) as Capabilities;

/** The modules the target emits: none that needs a capability it does not emit yet. */
const supported = new WeakMap<UfModule, boolean>();

/**
 * Whether the target emits a module. One that needs a capability it does not emit yet has no
 * Ember output: the compile reports the capability's UF4001 error, and the case skips.
 */
function emits(module: UfModule): boolean {
  let known = supported.get(module);
  if (known === undefined) {
    known = true;
    for (const name of requiredCapabilities(module).keys()) {
      if (!SUPPORTED.has(name) && !(name in BY_DESIGN)) known = false;
    }
    supported.set(module, known);
  }
  return known;
}

/**
 * What keeps the target from emitting a component's context, with where: a provider's marker
 * sits in its root element, where the root's descendants find it and no sibling of the root does,
 * so a component that provides needs one.
 */
function contextProblem(component: UfComponent): { message: string; span: Span } | undefined {
  const provide = component.setup.find((item) => item.kind === "Provide");
  if (!provide || component.render.kind === "Element") return undefined;
  return {
    message:
      "`provide` needs a root element on Ember: the provided values' marker sits in it, and a later sibling of a marker outside it would find it. See uxfront-com/unframework#236.",
    span: provide.span,
  };
}

/**
 * The Ember 7.4 target: one `.gts` file per component. A component with no state of its own is
 * a template-only component (`TOC`); any other is a `@glimmer/component` class, whose template
 * reads each expression the template language cannot hold through a member of the class
 * (`component.ts`).
 */
export const ember: Target = defineTarget({
  name: "ember",
  framework: { package: "ember-source", range: ">=7.4 <8" },
  capabilities: CAPABILITIES,
  emit(component: UfComponent, context: EmitContext): OutputFile[] {
    if (!emits(context.module)) return [];
    const unsupported = contextProblem(component);
    if (unsupported) {
      context.report({ code: "UF4001", severity: "error", ...unsupported });
      return [];
    }
    return [{ path: `${component.name}.gts`, contents: emitComponent(component, context) }];
  },
  // The `composables` cell is unsupported, so the compile reports UF4001 for each use, and the
  // case has no Ember output.
  emitComposable: () => [],
  emitDirective,
});

export default ember;
