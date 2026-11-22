import type { TOC } from "@ember/component/template-only";

export interface HeaderSignature {
  Element: HTMLElementTagNameMap["header"];
}

export const Header: TOC<HeaderSignature> = <template><header class="header" ...attributes>Site</header></template>;
