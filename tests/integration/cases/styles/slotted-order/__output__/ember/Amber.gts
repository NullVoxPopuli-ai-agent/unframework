import type { TOC } from "@ember/component/template-only";
import "./Amber.uf.tsx.css";

export interface AmberSignature {
  Blocks: { default: [] };
  Element: HTMLElementTagNameMap["div"];
}

const Amber: TOC<AmberSignature> = <template><div class="amber" data-uf-c97301b3="" ...attributes>{{yield}}</div></template>;

export default Amber;
