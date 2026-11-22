import type { TOC } from "@ember/component/template-only";

export interface HelloSignature {
  Element: HTMLElementTagNameMap["p"];
}

const Hello: TOC<HelloSignature> = <template><p class="greeting" ...attributes>Hello, world!</p></template>;

export default Hello;
