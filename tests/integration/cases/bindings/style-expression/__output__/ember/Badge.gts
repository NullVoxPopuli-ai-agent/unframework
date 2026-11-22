import Component from "@glimmer/component";
import { htmlSafe } from "@ember/template";

export interface BadgeProps {
  label: string;
  tone?: string;
}

export interface BadgeSignature {
  Args: BadgeProps;
  Element: HTMLElementTagNameMap["span"];
}

export default class Badge extends Component<BadgeSignature> {
  get value1() {
    return styleText([["", this.args.tone]]);
  }

  <template><span class="badge" style={{this.value1}} ...attributes>{{@label}}</span></template>
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
