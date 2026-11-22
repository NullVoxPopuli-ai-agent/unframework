import type { TOC } from "@ember/component/template-only";

export interface CardSignature {
  Element: HTMLElementTagNameMap["p"];
}

export const Card: TOC<CardSignature> = <template><p ...attributes>Card</p></template>;
