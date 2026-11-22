import Component from "@glimmer/component";
import { button as button_1 } from "virtual:styleframe";
import "virtual:styleframe.css";

export interface ButtonSignature {
  Args: { label: string; size?: "sm" | "lg"; tone?: "neutral" | "primary" };
  Element: HTMLElementTagNameMap["button"];
}

export default class Button extends Component<ButtonSignature> {
  get value1() {
    return classNames(button_1({ size: this.args.size, tone: this.args.tone }));
  }

  <template><button type="button" class={{this.value1}} ...attributes>{{@label}}</button></template>
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
