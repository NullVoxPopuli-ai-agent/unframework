import type { TOC } from "@ember/component/template-only";

export interface CardSignature {
  Blocks: { header: []; default: []; footer: [] };
  Element: HTMLElementTagNameMap["article"];
}

const Card: TOC<CardSignature> = <template><article
    class="card"
    ...attributes
  ><header>{{yield to="header"}}</header><div class="body">{{yield}}</div><footer>{{yield to="footer"}}</footer></article></template>;

export default Card;
