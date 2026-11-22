import type { TOC } from "@ember/component/template-only";

export interface TransitionComponentSignature {
  Element: HTMLElementTagNameMap["p"];
}

const TransitionComponent: TOC<TransitionComponentSignature> = <template><p class="note" ...attributes>Plain child</p></template>;

export default TransitionComponent;
