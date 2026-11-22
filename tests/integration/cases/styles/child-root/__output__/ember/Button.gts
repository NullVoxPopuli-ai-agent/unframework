import type { TOC } from "@ember/component/template-only";

export interface ButtonSignature {
  Args: { text: string };
  Element: HTMLElementTagNameMap["button"];
}

const Button: TOC<ButtonSignature> = <template><button
    type="button"
    class="button"
    ...attributes
  ><span class="icon" aria-hidden="true">+</span>{{@text}}</button></template>;

export default Button;
