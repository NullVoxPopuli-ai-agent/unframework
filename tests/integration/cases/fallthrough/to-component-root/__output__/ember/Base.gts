import type { TOC } from "@ember/component/template-only";

export interface BaseSignature {
  Args: { text: string };
  Element: HTMLElementTagNameMap["button"];
}

const Base: TOC<BaseSignature> = <template><button type="button" class="base" ...attributes>{{@text}}</button></template>;

export default Base;
