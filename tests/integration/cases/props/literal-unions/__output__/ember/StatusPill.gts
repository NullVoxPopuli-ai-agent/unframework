import Component from "@glimmer/component";

export interface StatusPillProps {
  status: "active" | "paused" | "archived";
  size?: "small" | "large";
  level?: 1 | 2 | 3;
}

export interface StatusPillSignature {
  Args: StatusPillProps;
  Element: HTMLElementTagNameMap["span"];
}

export default class StatusPill extends Component<StatusPillSignature> {
  get size() {
    return this.args.size === undefined ? "small" : this.args.size;
  }

  get level() {
    return this.args.level === undefined ? 1 : this.args.level;
  }

  get value1() {
    return this.args.status === "active"
      ? "Active"
      : this.args.status === "paused"
        ? "Paused"
        : "Archived";
  }

  get value2() {
    return this.level === 3 ? " (critical)" : "";
  }

  get value3() {
    return classNames(
      "pill",
      `pill-${this.args.status}`,
      `pill-${this.size}`,
      `pill-level-${this.level}`,
    );
  }

  <template><span class={{this.value3}} ...attributes>{{this.value1}}{{this.value2}}</span></template>
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
