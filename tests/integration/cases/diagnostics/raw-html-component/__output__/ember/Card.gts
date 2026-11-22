import type { TOC } from "@ember/component/template-only";

export interface CardSignature {
  Args: { heading: string };
  Element: HTMLElementTagNameMap["section"];
}

export const Card: TOC<CardSignature> = <template><section class="card" ...attributes><h2>{{@heading}}</h2></section></template>;
