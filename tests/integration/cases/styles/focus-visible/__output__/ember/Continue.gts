import type { TOC } from "@ember/component/template-only";
import "./Continue.uf.tsx.css";

export interface ContinueSignature {
  Args: { text: string };
  Element: HTMLElementTagNameMap["button"];
}

const Continue: TOC<ContinueSignature> = <template><button type="button" class="continue" data-uf-bb3adc28="" ...attributes>{{@text}}</button></template>;

export default Continue;
