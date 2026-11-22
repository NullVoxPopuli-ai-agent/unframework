import type { TOC } from "@ember/component/template-only";

export interface HintSignature {
  Element: HTMLElementTagNameMap["p"];
}

export const Hint: TOC<HintSignature> = <template><p ...attributes>Hint</p></template>;
