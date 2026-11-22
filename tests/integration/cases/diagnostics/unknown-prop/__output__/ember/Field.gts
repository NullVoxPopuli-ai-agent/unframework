import type { TOC } from "@ember/component/template-only";

export interface FieldSignature {
  Args: { label: string };
  Element: HTMLElementTagNameMap["label"];
}

export const Field: TOC<FieldSignature> = <template><label ...attributes>{{@label}} <input type="text"></label></template>;
