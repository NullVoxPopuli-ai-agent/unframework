import type { TOC } from "@ember/component/template-only";

export interface CardIconSignature {
  Args: { symbol: string };
  Element: HTMLElementTagNameMap["span"];
}

export const CardIcon: TOC<CardIconSignature> = <template><span class="icon" aria-hidden="true" ...attributes>{{@symbol}}</span></template>;
