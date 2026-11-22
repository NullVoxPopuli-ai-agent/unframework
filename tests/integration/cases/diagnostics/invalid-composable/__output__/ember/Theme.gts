import type { TOC } from "@ember/component/template-only";

export interface ThemeSignature {
  Element: HTMLElementTagNameMap["p"];
}

const Theme: TOC<ThemeSignature> = <template><p ...attributes>Theme</p></template>;

export default Theme;
