import type { TOC } from "@ember/component/template-only";
import { CardIcon } from "./CardIcon.gts";

export interface CardSignature {
  Args: { title: string };
  Element: HTMLElementTagNameMap["div"];
}

const Card: TOC<CardSignature> = <template><div
    class="card"
    ...attributes
  ><CardIcon @symbol="+" /><h3>{{@title}}</h3><CardIcon @symbol="-" /></div></template>;

export default Card;
