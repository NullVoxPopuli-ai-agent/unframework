import Component from "@glimmer/component";

export interface BannerProps {
  message: string;
  tone: string;
  emphasis?: string | null;
}

export interface BannerSignature {
  Args: BannerProps;
  Element: HTMLElementTagNameMap["div"];
}

export default class Banner extends Component<BannerSignature> {
  get value1() {
    return classNames(this.args.emphasis);
  }

  get value2() {
    return classNames(`banner-footer banner-footer-${this.args.tone}`);
  }

  get value3() {
    return classNames("banner", this.args.tone);
  }

  <template><div
      class={{this.value3}}
      role="note"
      ...attributes
    ><p class={{this.value1}}>{{@message}}</p><p class={{this.value2}}>Shown to every visitor.</p></div></template>
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
