import Component from "@glimmer/component";

export interface NavItemProps {
  label: string;
  href: string;
  active: boolean;
  muted: boolean;
  danger?: boolean;
}

export interface NavItemSignature {
  Args: NavItemProps;
  Element: HTMLElementTagNameMap["a"];
}

export default class NavItem extends Component<NavItemSignature> {
  get danger() {
    return this.args.danger === undefined ? false : this.args.danger;
  }

  get value1() {
    return this.args.active ? "page" : undefined;
  }

  get value2() {
    return classNames(
      this.args.active && "active",
      this.args.muted && "nav-item-muted",
      this.danger && "nav-item-danger",
      this.danger && "text-danger",
    );
  }

  <template><a
      href={{@href}}
      class={{this.value2}}
      aria-current={{enumeratedValue this.value1}}
      ...attributes
    >{{@label}}</a></template>
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

/** An enumerated attribute's value: a boolean as its name, any other value as it is. */
function enumeratedValue<T>(value: T): Exclude<T, boolean> | "true" | "false" {
  return typeof value === "boolean"
    ? (String(value) as "true" | "false")
    : (value as Exclude<T, boolean>);
}
