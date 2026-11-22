import type { TOC } from "@ember/component/template-only";
import "./Blue.uf.tsx.css";

export interface BlueSignature {
  Blocks: { default: [] };
  Element: HTMLElementTagNameMap["div"];
}

const Blue: TOC<BlueSignature> = <template><div class="blue" data-uf-721c504a="" ...attributes>{{yield}}</div></template>;

export default Blue;
