import type { TOC } from "@ember/component/template-only";

export interface ItemSignature {
  Element: HTMLElementTagNameMap["span"];
}

export const Item: TOC<ItemSignature> = <template><span ...attributes>Item</span></template>;
