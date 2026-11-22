import Component from "@glimmer/component";
import { chip } from "virtual:fixture-engine";
import "virtual:fixture-engine.css";

export interface ChipSignature {
  Args: { label: string; tone?: "plain" | "accent" };
  Element: HTMLElementTagNameMap["span"];
}

export default class Chip extends Component<ChipSignature> {
  get value1() {
    return classNames(chip(this.args.tone));
  }

  <template><span class={{this.value1}} ...attributes>{{@label}}</span></template>
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
