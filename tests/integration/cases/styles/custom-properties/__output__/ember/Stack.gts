import Component from "@glimmer/component";
import { htmlSafe } from "@ember/template";
import "./Stack.uf.tsx.css";

export interface StackSignature {
  Args: { gap: string; accent: string };
  Element: HTMLElementTagNameMap["ul"];
}

export default class Stack extends Component<StackSignature> {
  get value1() {
    return styleText([
      ["--gap", this.args.gap],
      ["--accent", this.args.accent],
    ]);
  }

  <template><ul
      class="stack"
      style={{this.value1}}
      data-uf-e3a22111=""
      ...attributes
    ><li class="item" data-uf-e3a22111="">One</li><li class="item" data-uf-e3a22111="">Two</li><li
      class="item"
      data-uf-e3a22111=""
    >Three</li></ul></template>
}

/**
 * A style from its declarations, those whose value is nullish left out, marked safe. A
 * declaration without a property is a whole style: a declaration list, or an object whose keys
 * may be in camel case, as Vue's `normalizeStyle` reads them.
 */
function styleText(
  declarations: readonly (readonly [string, unknown])[],
): ReturnType<typeof htmlSafe> | undefined {
  const parts: string[] = [];
  const add = (property: string, value: unknown): void => {
    if (value === undefined || value === null) return;
    if (property) parts.push(`${property}: ${String(value)}`);
    else if (typeof value === "string") parts.push(value.trim().replace(/;$/, ""));
    else if (typeof value === "object") {
      for (const [key, each] of Object.entries(value)) {
        add(
          key.startsWith("--")
            ? key
            : key.replace(/[A-Z]/g, (letter) => `-${letter.toLowerCase()}`),
          each,
        );
      }
    }
  };
  for (const [property, value] of declarations) add(property, value);
  const text = parts.filter(Boolean).join("; ");
  return text ? htmlSafe(text) : undefined;
}
