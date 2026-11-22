import { CAPABILITY_NAMES, defineTarget, requiredCapabilities } from "@unframework.dev/codegen";
import type {
  Capabilities,
  CapabilityCell,
  CapabilityName,
  EmitContext,
  OutputFile,
  Target,
} from "@unframework.dev/codegen";
import type { UfComponent, UfModule } from "@unframework.dev/ir";

import { emitComponent } from "./component.ts";

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
  // A Glimmer `style` is one string, which Ember asks to be marked safe.
  interactivity: {
    support: "emulated",
    helper: "Watcher",
    note: "State, derived values, listeners and template refs are tracked fields, getters, `{{on}}` and an inline modifier. Glimmer has no effects, so a watcher and a watchEffect go through inline helpers, Watcher and Effect, that the template calls before and after its content: a watcher calls back right after the render that sees a change, with Vue's previous value, change test and cleanup timing, and an effect runs once the render settles. The lifecycle hooks run once the first render settles, and never on the server.",
  },
  "style-binding": {
    support: "emulated",
    helper: "styleText",
    note: "A Glimmer `style` is one string, so an inline helper, styleText, writes the declarations whose value is present and marks the string safe with htmlSafe, as Ember asks of a bound style.",
  },
};

/**
 * What the Ember target emits so far: the static and props subset of M1. Each other cell is
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
  // `{{on}}` adds the listener to its element, with `addEventListener`'s options, and the
  // handler runs as the event is dispatched.
  "interactivity",
  "event-capture",
  "event-once",
  "event-passive",
  "event-semantics",
  "conditional-event-control",
]);

/** The capabilities each part of the target that is not built yet holds. */
const NOT_YET: readonly { reason: string; names: readonly CapabilityName[] }[] = [
  {
    reason: "Ids, `nextTick`, models and directives are not emitted yet.",
    names: [
      "use-id",
      "next-tick",
      "late-prop",
      "two-way-binding",
      "model-array",
      "model-modifiers",
      "directive",
      // `{{#each}}` keeps a keyed row's element, and `<select>` sets `size` before its options,
      // but the cases that show it type or pick in the browser.
      "keyed-identity",
      "listbox",
    ],
  },
  {
    reason:
      "Child components, slots, models, context and the built-in components are not emitted yet.",
    names: [
      "component",
      "component-event",
      "default-slot",
      "named-slot",
      "scoped-slot",
      "slot-fallback",
      "default-slot-presence",
      "slot-forwarding",
      "model",
      "fallthrough",
      "expose",
      "context",
      "reactive-context",
      "dynamic-component",
      "teleport",
      "transition",
      "generic-components",
      "generic-slot-props",
      "async-setup",
    ],
  },
  {
    reason: "Composables are not emitted yet.",
    names: ["composables", "composable-effect-order"],
  },
  {
    reason: "Scoped stylesheets are not emitted yet.",
    names: ["scoped-styles", "child-root-scope", "slotted-styles", "sheet-order"],
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
    EMULATED[name] ?? (SUPPORTED.has(name) ? NATIVE : notYet(reasonFor(name))),
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
      if (!SUPPORTED.has(name)) known = false;
    }
    supported.set(module, known);
  }
  return known;
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
    return [{ path: `${component.name}.gts`, contents: emitComponent(component, context) }];
  },
  // The `composables` and `directive` cells are unsupported, so the compile reports UF4001 for
  // each use, and the case has no Ember output.
  emitComposable: () => [],
  emitDirective: () => [],
});

export default ember;
