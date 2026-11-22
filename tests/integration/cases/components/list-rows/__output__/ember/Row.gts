import Component from "@glimmer/component";

export interface RowSignature {
  Args: { name: string; done: boolean };
  Element: HTMLElementTagNameMap["div"];
}

export default class Row extends Component<RowSignature> {
  get value1() {
    return this.args.done ? " (done)" : "";
  }

  get value2() {
    return classNames("row", this.args.done && "done");
  }

  <template><div role="listitem" class={{this.value2}} ...attributes>{{@name}}{{this.value1}}</div></template>
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
