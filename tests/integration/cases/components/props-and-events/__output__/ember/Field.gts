import Component from "@glimmer/component";

export interface FieldProps {
  label: string;
  tone?: "info" | "warn";
}

export interface FieldEvents {
  onClear?: (label: string) => void;
}

export interface FieldSignature {
  Args: FieldProps & FieldEvents;
  Element: HTMLElementTagNameMap["div"];
}

export default class Field extends Component<FieldSignature> {
  get tone() {
    return this.args.tone === undefined ? "info" : this.args.tone;
  }

  listener1 = () => this.args.onClear?.(this.args.label);

  get value1() {
    return classNames("field", this.tone);
  }

  <template><div
      class={{this.value1}}
      ...attributes
    ><span>{{@label}}</span><button
      type="button"
      {{on "click" this.listener1}}
    >Clear {{@label}}</button></div></template>
}

/** A class as clsx builds it: strings, arrays and toggle objects, empty tokens left out. */
function classNames(...values: unknown[]): string | undefined {
  const tokens: string[] = [];
  const add = (value: unknown): void => {
    if (!value) return;
    if (typeof value === "string" || typeof value === "number") tokens.push(String(value));
    else if (Array.isArray(value)) for (const each of value) add(each);
    else if (typeof value === "object") {
      for (const [name, on] of Object.entries(value)) if (on) tokens.push(name);
    }
  };
  for (const value of values) add(value);
  return tokens.length ? tokens.join(" ") : undefined;
}
