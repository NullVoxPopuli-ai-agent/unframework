import type { TOC } from "@ember/component/template-only";
import Item from "./Item.gts";

export interface MenuSignature {
  Args: { entries: string[] };
  Element: HTMLElementTagNameMap["ul"];
}

const Menu: TOC<MenuSignature> = <template><ul
    aria-label="Menu"
    ...attributes
  >{{#each @entries key="@identity" as |entry|}}<Item @label={{entry}} />{{/each}}</ul></template>;

export default Menu;
