import type { TOC } from "@ember/component/template-only";

interface Fruit {
  id: string;
  name: string;
  children: Fruit[];
}

export interface CountSignature {
  Args: { items: Fruit[] };
  Element: HTMLElementTagNameMap["p"];
}

export const Count: TOC<CountSignature> = <template><p ...attributes>{{@items.length}} fruits</p></template>;
