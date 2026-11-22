import type { TOC } from "@ember/component/template-only";

export interface CardSignature {
  Blocks: { title: [] };
  Element: HTMLElementTagNameMap["div"];
}

const Card: TOC<CardSignature> = <template><div
    class="card"
    ...attributes
  ><h3>{{#if (has-block "title")}}{{yield to="title"}}{{else}}Untitled{{/if}}</h3></div></template>;

export default Card;
