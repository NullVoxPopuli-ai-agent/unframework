import Component from "@glimmer/component";
import { htmlSafe } from "@ember/template";

export interface UsageMeterProps {
  label: string;
  percent: number;
  colour: string;
  thickness: number;
}

export interface UsageMeterSignature {
  Args: UsageMeterProps;
  Element: HTMLElementTagNameMap["div"];
}

export default class UsageMeter extends Component<UsageMeterSignature> {
  get value1() {
    return styleText([
      ["color", this.args.colour],
      ["font-weight", 700],
      ["line-height", 1.5],
      ["margin-bottom", "4px"],
    ]);
  }

  get value2() {
    return styleText([
      ["width", `${this.args.percent}%`],
      ["height", "100%"],
      ["background-color", "var(--meter-colour)"],
    ]);
  }

  get value3() {
    return styleText([
      ["--meter-colour", this.args.colour],
      ["--meter-value", this.args.percent],
      ["width", "200px"],
      ["height", "12px"],
      ["border-style", "solid"],
      ["border-width", `${this.args.thickness}px`],
      ["border-color", this.args.colour],
    ]);
  }

  get value4() {
    return styleText([
      ["color", this.args.colour],
      ["font-family", '"UF Test Sans", sans-serif'],
    ]);
  }

  <template><div
      class="usage-meter"
      ...attributes
    ><p style={{this.value1}}>{{@label}}: {{@percent}}%</p><div
      role="progressbar"
      aria-label={{@label}}
      aria-valuemin="0"
      aria-valuemax="100"
      aria-valuenow={{enumeratedValue @percent}}
      style={{this.value3}}
    ><div style={{this.value2}}></div></div><p
      class="usage-meter-caption"
      style={{this.value4}}
    >{{@percent}} of 100 used</p></div></template>
}

/** An enumerated attribute's value: a boolean as its name, any other value as it is. */
function enumeratedValue<T>(value: T): Exclude<T, boolean> | "true" | "false" {
  return typeof value === "boolean"
    ? (String(value) as "true" | "false")
    : (value as Exclude<T, boolean>);
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
