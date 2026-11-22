import type { TOC } from "@ember/component/template-only";

export interface HintSignature {
  Args: { text: string };
  Element: HTMLElementTagNameMap["small"];
}

export const Hint: TOC<HintSignature> = <template><small class="hint" ...attributes>{{@text}}</small></template>;
