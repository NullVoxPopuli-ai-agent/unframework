import Component from "@glimmer/component";

export interface PlanProps {
  name: string;
  price: number;
  href: string;
  featured?: boolean;
  note?: string;
}

export interface PlanSignature {
  Args: PlanProps;
  Element: HTMLElementTagNameMap["article"];
}

export default class Plan extends Component<PlanSignature> {
  get featured() {
    return this.args.featured === undefined ? false : this.args.featured;
  }

  get value1() {
    return classNames(this.featured ? "plan featured" : "plan");
  }

  <template><article
      class={{this.value1}}
      aria-label={{@name}}
      ...attributes
    ><h2>{{@name}}</h2><p>{{@price}} EUR a month</p>{{#if @note}}<p class="note">{{@note}}</p>{{else}}<p
      class="note"
    >No commitment.</p>{{/if}}<a href={{@href}}>Choose {{@name}}</a></article></template>
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
