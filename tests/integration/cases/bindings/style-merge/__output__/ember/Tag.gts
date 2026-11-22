import Component from "@glimmer/component";
import { htmlSafe } from "@ember/template";

export interface TagProps {
  label: string;
  colour?: string;
  weight?: number;
  indent?: string;
}

export interface TagSignature {
  Args: TagProps;
  Element: HTMLElementTagNameMap["span"];
}

export default class Tag extends Component<TagSignature> {
  get value1() {
    return styleText([
      ["display", "inline-block"],
      ["padding", "2px 8px"],
      ["border-style", "solid"],
      ["border-width", "1px"],
      ["border-color", this.args.colour ?? "#5a5a5a"],
      ["color", this.args.colour],
      ["font-weight", this.args.weight],
      ["margin-left", this.args.indent],
    ]);
  }

  <template><span class="tag" style={{this.value1}} ...attributes>{{@label}}</span></template>
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
