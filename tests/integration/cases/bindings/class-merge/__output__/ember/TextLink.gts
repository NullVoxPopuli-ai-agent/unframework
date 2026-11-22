import Component from "@glimmer/component";

interface LinkAttributes {
  class?: string;
  title?: string;
  rel?: string;
}

interface RowAttributes {
  class: string;
  id?: string;
}

export interface TextLinkProps {
  href: string;
  label: string;
  strong: boolean;
  link: LinkAttributes;
  row: RowAttributes;
}

export interface TextLinkSignature {
  Args: TextLinkProps;
  Element: HTMLElementTagNameMap["p"];
}

export default class TextLink extends Component<TextLinkSignature> {
  get value1() {
    return classNames("text-link", this.args.link.class);
  }

  get value2() {
    return classNames(this.args.row.class, "link-row", this.args.strong && "link-row-strong");
  }

  <template><p
      class={{this.value2}}
      id={{@row.id}}
      ...attributes
    ><a href={{@href}} class={{this.value1}} title={{@link.title}} rel={{@link.rel}}>{{@label}}</a></p></template>
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
