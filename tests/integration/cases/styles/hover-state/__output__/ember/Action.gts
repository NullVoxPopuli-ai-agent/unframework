import type { TOC } from "@ember/component/template-only";
import "./Action.uf.tsx.css";

export interface ActionSignature {
  Args: { text: string };
  Element: HTMLElementTagNameMap["button"];
}

const Action: TOC<ActionSignature> = <template><button type="button" class="action" data-uf-6173c12c="" ...attributes>{{@text}}</button></template>;

export default Action;
