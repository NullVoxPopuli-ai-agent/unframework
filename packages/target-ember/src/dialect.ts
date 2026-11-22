// Glimmer markup (Ember's template language in strict mode): `{{path}}` mustaches, `{{#if}}` and
// keyed `{{#each}}` blocks, and `{{` written `\{{` in text. A template holds no JavaScript, so
// every expression reaches the template through the class (`ComponentPlan.value`). Glimmer keeps
// whitespace as written, at the edges of an element's content and between elements, so the
// printer adds none.
import {
  escapeHtmlAttribute,
  escapeHtmlText,
  referencedBindings,
  staticClassValue,
  staticStyleValue,
} from "@unframework.dev/codegen";
import type { MarkupDialect, TextPosition } from "@unframework.dev/codegen";
import type {
  ComponentNode,
  ElementNode,
  EventAttribute,
  ListenerAttribute,
  ModelAttribute,
} from "@unframework.dev/ir";

/** What the dialect asks of the component's class. */
export interface DialectHost {
  value(code: string, subexpression: boolean, at?: object, typed?: boolean): string;
  row(source: string, item: string, index: string | undefined, at: object): string;
  classCode(parts: Parameters<MarkupDialect["classAttribute"]>[0]): string;
  styleCode(parts: Parameters<MarkupDialect["styleAttribute"]>[0]): string;
  rawHtml(code: string): string;
  /** A row variable's name in the template, which no tag the template writes takes. */
  rowName(name: string): string;
  /** The module helper that writes an enumerated attribute's boolean as its name. */
  enumerated(): string;
  /** A form control's `v-model`: what shows the state, and what writes it back. */
  model(attribute: ModelAttribute, value: string, element: ElementNode): string[];
  /**
   * What an `<option>` of a `v-model`'s `<select>` adds beside its value: whether the state
   * holds it, `selected={{…}}`, or nothing for any other option.
   */
  optionSelected(element: ElementNode, value: string): string;
  /** A `<textarea>`'s text: its state's first value, which `modelText` makes its value. */
  modelContent(value: string): string;
  /** The handler of a child's event, which its `@onChange` argument takes. */
  componentListener(attribute: ListenerAttribute, node: ComponentNode): string;
  /** The modifier that holds an element in a template ref's member. */
  templateRef(name: string): string;
  /** The handler a listener's `{{on}}` takes: a member, or a call of one with row variables. */
  listener(attribute: EventAttribute, at: object): string;
  /** What holds a node of the template: a branch's `If`, an element's parent. */
  parentOf(node: object): object | undefined;
}

/** `{{` as Glimmer's escape, so the text stays text. */
const escapeMustaches = (text: string) => text.replace(/\{\{/g, "\\{{");

/** The elements whose text Glimmer's tokenizer reads a leading line feed of as HTML does. */
const LEADING_LINE_FEED = new Set(["pre", "textarea", "listing"]);

/**
 * Text as Glimmer reads it back. Inside a `<pre>`, Glimmer drops the line feed that starts a
 * text after a mustache, as HTML drops the one after the start tag, so that one is a reference.
 */
function escapeText(text: string, position: TextPosition): string {
  const escaped = escapeMustaches(escapeHtmlText(text));
  const element = position.element?.tag;
  if (!position.first && element && LEADING_LINE_FEED.has(element) && escaped.startsWith("\n")) {
    return `&#10;${escaped.slice(1)}`;
  }
  return escaped;
}

/** A static attribute value, as Glimmer reads it back. */
const attributeValue = (value: string) => escapeMustaches(escapeHtmlAttribute(value));

/** Vue's enumerated attributes (`isEnumeratedAttr`), besides ARIA's, which take a boolean's name. */
const ENUMERATED: ReadonlySet<string> = new Set(["contenteditable", "draggable", "spellcheck"]);

/** ARIA's attributes whose value ARIA types as a string or ID references: never a boolean. */
const ARIA_STRINGS: ReadonlySet<string> = new Set([
  "aria-activedescendant",
  "aria-braillelabel",
  "aria-brailleroledescription",
  "aria-controls",
  "aria-describedby",
  "aria-description",
  "aria-details",
  "aria-errormessage",
  "aria-flowto",
  "aria-keyshortcuts",
  "aria-label",
  "aria-labelledby",
  "aria-owns",
  "aria-placeholder",
  "aria-roledescription",
  "aria-valuetext",
]);

/** Whether an attribute takes a boolean's name: ARIA's, and the enumerated ones. */
function isEnumerated(name: string): boolean {
  if (ARIA_STRINGS.has(name)) return false;
  return name.startsWith("aria-") || ENUMERATED.has(name.toLowerCase());
}

/** The key Glimmer's `{{#each}}` takes: a path of the item, the item itself, or its index. */
function eachKey(key: string, item: string, index: string | undefined): string {
  if (key === item) return "@identity";
  if (index !== undefined && key === index) return "@index";
  const path = new RegExp(`^${item}((?:\\??\\.[A-Za-z_$][\\w$]*)+)$`).exec(key);
  if (path) return path[1]!.replace(/\?\./g, ".").slice(1);
  return "@identity";
}

/** The Glimmer dialect, reading expressions through `host`. */
export function emberDialect(host: DialectHost): MarkupDialect {
  return {
    name: "ember",
    escapeText,
    attribute: (name, value, _tag, context) => {
      const text = `${name}="${attributeValue(value)}"`;
      if (name !== "value" || context?.element.tag !== "option") return text;
      return `${text}${host.optionSelected(context.element, JSON.stringify(value))}`;
    },
    voidElement: "html",
    stripsWhitespaceBetweenElements: false,
    stripsEdgeWhitespace: false,
    interpolation: (code, position) => `{{${host.value(code, false, position.container)}}}`,
    // Glimmer writes `true` as an empty attribute and leaves `false` out, where an ARIA or an
    // enumerated attribute takes the boolean's name (`aria-expanded="false"`).
    boundAttribute: (name, code, { element }) => {
      if (isEnumerated(name)) {
        return `${name}={{${host.enumerated()} ${host.value(code, true, element)}}}`;
      }
      const text = `${name}={{${host.value(code, false, element)}}}`;
      if (name !== "value" || element.tag !== "option") return text;
      return `${text}${host.optionSelected(element, code)}`;
    },
    classAttribute: (parts, { element }) => [
      {
        name: "class",
        text: parts.every((part) => part.kind === "Static")
          ? `class="${attributeValue(staticClassValue(parts))}"`
          : `class={{${host.value(host.classCode(parts), false, element)}}}`,
      },
    ],
    styleAttribute: (parts, { element }) => [
      {
        name: "style",
        text: parts.every((part) => part.kind === "Static")
          ? `style="${attributeValue(staticStyleValue(parts))}"`
          : `style={{${host.value(host.styleCode(parts), false, element)}}}`,
      },
    ],
    conditional: (branches) => {
      const at = host.parentOf(branches[0]!.branch);
      return [
        {
          kind: "block",
          segments: branches.map(({ condition, branch }, index) => ({
            open:
              index === 0
                ? `{{#if ${host.value(condition!, true, at)}}}`
                : condition === undefined
                  ? "{{else}}"
                  : `{{else if ${host.value(condition, true, at)}}}`,
            content: { kind: "nodes", nodes: branch.children, container: branch },
          })),
          close: "{{/if}}",
        },
      ];
    },
    list: ({ node, source, item: itemName, index: indexName, key }) => {
      const item = host.rowName(itemName);
      const index = indexName === undefined ? undefined : host.rowName(indexName);
      // The key is no expression in Glimmer (`key="@index"`): only the body reads the index.
      const readsIndex =
        index !== undefined &&
        node.index !== undefined &&
        referencedBindings(node.body).has(node.index);
      const value = host.row(source, item, readsIndex ? index : undefined, node);
      const params = readsIndex ? `${item} ${index}` : item;
      return [
        {
          kind: "block",
          segments: [
            {
              open: `{{#each ${value} key="${eachKey(key, item, index)}" as |${params}|}}`,
              content: { kind: "nodes", nodes: [node.body], container: node },
            },
          ],
          close: "{{/each}}",
        },
      ];
    },
    // What a capability cell leaves unsupported prints nothing: the compile reports UF4001 as an
    // error there, so the case has no Ember output.
    // `on` is a keyword of strict mode, which takes `addEventListener`'s options as named
    // arguments.
    eventAttribute: ({ attribute }, { element }) => {
      const options = (["capture", "once", "passive"] as const)
        .filter((option) => attribute[option])
        .map((option) => ` ${option}=true`)
        .join("");
      const handler = host.listener(attribute, element);
      return [{ name: "on", text: `{{on "${attribute.event}" ${handler}${options}}}` }];
    },
    refAttribute: ({ name }) => [{ name: "ref", text: host.templateRef(name) }],
    directiveAttribute: () => [],
    // A child's props and events are its arguments (ADR-0053): `@label="Name"`,
    // `@count={{this.total}}`, and `@onClear={{this.reset}}` for its `clear` event.
    propAttribute: ({ name, code, literal }, { component }) => [
      {
        name: `@${name}`,
        text:
          literal !== undefined
            ? `@${name}="${attributeValue(literal)}"`
            : `@${name}={{${host.value(code, false, component, true)}}}`,
      },
    ],
    componentEvent: ({ attribute }, { component }) => {
      const name = `@on${attribute.event.charAt(0).toUpperCase()}${attribute.event.slice(1)}`;
      return [{ name, text: `${name}={{${host.componentListener(attribute, component)}}}` }];
    },
    // Ember's server writes a `<textarea>`'s `value` as an attribute: its text is the state's
    // first value, as Vue's server renders it, and `modelText` writes the property in the browser.
    modelContent: ({ value }) => host.modelContent(value),
    modelAttribute: ({ attribute, value }, { element }) =>
      host.model(attribute, value, element).map((text) => ({ name: "model", text })),
    modelBinding: () => [],
    fills: () => [],
    slotOutlet: () => [],
    dynamic: () => [],
    teleport: () => [],
    transition: () => [],
    rawHtmlContent: (code) => host.rawHtml(code),
  };
}
