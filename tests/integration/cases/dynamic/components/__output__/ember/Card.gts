import type { TOC } from "@ember/component/template-only";

export interface CardSignature {
  Args: { label: string };
  Element: HTMLElementTagNameMap["div"];
}

const Card: TOC<CardSignature> = <template><div class="card" ...attributes><strong>{{@label}}</strong></div></template>;

export default Card;
