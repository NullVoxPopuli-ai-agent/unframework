import Component from "@glimmer/component";

export interface NoticeSignature {
  Args: { text: string; tone: "info" | "quiet" };
  Element: HTMLElementTagNameMap["p"];
}

export default class Notice extends Component<NoticeSignature> {
  get value1() {
    return classNames("notice", this.args.tone);
  }

  <template><p role="status" class={{this.value1}} ...attributes>{{@text}}</p></template>
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
