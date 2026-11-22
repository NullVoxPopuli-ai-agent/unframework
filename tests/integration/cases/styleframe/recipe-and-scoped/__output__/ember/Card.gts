import Component from "@glimmer/component";
import { button } from "virtual:styleframe";
import "virtual:styleframe.css";
import "./Card.uf.tsx.css";

export interface CardSignature {
  Args: { title: string };
  Element: HTMLElementTagNameMap["article"];
}

export default class Card extends Component<CardSignature> {
  get value1() {
    return classNames("card", button({ size: "lg", tone: "primary" }));
  }

  <template><article
      class={{this.value1}}
      data-uf-9cfb6163=""
      ...attributes
    ><h2 class="title" data-uf-9cfb6163="">{{@title}}</h2></article></template>
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
