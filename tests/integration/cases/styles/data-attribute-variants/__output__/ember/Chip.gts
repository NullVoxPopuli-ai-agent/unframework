import Component from "@glimmer/component";
import "./Chip.uf.tsx.css";

export interface ChipSignature {
  Args: { label: string; variant?: "neutral" | "danger"; pressed?: boolean };
  Element: HTMLElementTagNameMap["button"];
}

export default class Chip extends Component<ChipSignature> {
  get variant() {
    return this.args.variant === undefined ? "neutral" : this.args.variant;
  }

  get pressed() {
    return this.args.pressed === undefined ? false : this.args.pressed;
  }

  get value1() {
    return this.pressed ? "on" : "off";
  }

  get value2() {
    return this.pressed ? "true" : "false";
  }

  <template><button
      type="button"
      class="chip"
      data-variant={{this.variant}}
      data-state={{this.value1}}
      aria-pressed={{enumeratedValue this.value2}}
      data-uf-69db3802=""
      ...attributes
    >{{@label}}</button></template>
}

/** An enumerated attribute's value: a boolean as its name, any other value as it is. */
function enumeratedValue<T>(value: T): Exclude<T, boolean> | "true" | "false" {
  return typeof value === "boolean"
    ? (String(value) as "true" | "false")
    : (value as Exclude<T, boolean>);
}
