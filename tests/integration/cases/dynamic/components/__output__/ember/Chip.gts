import type { TOC } from "@ember/component/template-only";

export interface ChipSignature {
  Args: { label: string };
  Element: HTMLElementTagNameMap["span"];
}

const Chip: TOC<ChipSignature> = <template><span class="chip" ...attributes>{{@label}}</span></template>;

export default Chip;
