import type { TOC } from "@ember/component/template-only";
import "./Mat.uf.tsx.css";

export interface MatSignature {
  Blocks: { default: [] };
  Element: HTMLElementTagNameMap["div"];
}

const Mat: TOC<MatSignature> = <template><div class="mat" data-uf-09929c4a="" ...attributes>{{yield}}</div></template>;

export default Mat;
