import type { TOC } from "@ember/component/template-only";
import "./Card.uf.tsx.css";

export interface CardSignature {
  Args: { title: string };
  Element: HTMLElementTagNameMap["section"];
}

const Card: TOC<CardSignature> = <template><section
    class="card"
    data-uf-bb60e985=""
    ...attributes
  ><h2 class="title" data-uf-bb60e985="">{{@title}}</h2></section></template>;

export default Card;
