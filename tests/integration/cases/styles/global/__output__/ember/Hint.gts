import type { TOC } from "@ember/component/template-only";

export interface HintSignature {
  Args: { text: string };
  Element: HTMLElementTagNameMap["p"];
}

const Hint: TOC<HintSignature> = <template><p class="hint" ...attributes>Tip: <span class="uf-highlight">{{@text}}</span></p></template>;

export default Hint;
