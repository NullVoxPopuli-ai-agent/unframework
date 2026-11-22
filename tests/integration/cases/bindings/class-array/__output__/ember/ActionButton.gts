import Component from "@glimmer/component";

export interface ActionButtonProps {
  label: string;
  size: "small" | "medium" | "large";
  primary: boolean;
  busy?: boolean;
  badge: number;
}

export interface ActionButtonSignature {
  Args: ActionButtonProps;
  Element: HTMLElementTagNameMap["button"];
}

export default class ActionButton extends Component<ActionButtonSignature> {
  get busy() {
    return this.args.busy === undefined ? false : this.args.busy;
  }

  get value1() {
    return classNames(
      "button",
      `button-${this.args.size}`,
      this.args.primary && "button-primary",
      this.busy && "is-busy",
      this.busy && "button-waiting",
      this.args.badge && "has-badge",
      this.args.primary ? "solid" : "outline",
    );
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
