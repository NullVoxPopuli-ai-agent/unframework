import type { TOC } from "@ember/component/template-only";

export interface ItemSignature {
  Args: { label: string };
  Element: HTMLElementTagNameMap["li"];
}

const Item: TOC<ItemSignature> = <template><li class="item" ...attributes>{{@label}}</li></template>;

export default Item;
