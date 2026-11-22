import Component from "@glimmer/component";
import { htmlSafe } from "@ember/template";

export interface ExcerptProps {
  title: string;
  text: string;
  fill: string;
  stroke: string;
}

export interface ExcerptSignature {
  Args: ExcerptProps;
  Element: HTMLElementTagNameMap["article"];
}

export default class Excerpt extends Component<ExcerptSignature> {
  get value1() {
    return styleText([
      ["-webkit-text-fill-color", this.args.fill],
      ["-webkit-text-stroke-color", this.args.stroke],
      ["-webkit-text-stroke-width", "1px"],
      ["color", "rgb(0, 0, 0)"],
    ]);
  }

  <template><article
      class="excerpt"
      ...attributes
    ><h2 style={{this.value1}}>{{@title}}</h2><p
      style="display: -webkit-box; -webkit-box-orient: vertical; -webkit-line-clamp: 2; overflow: hidden; width: 240px"
    >{{@text}}</p></article></template>
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
