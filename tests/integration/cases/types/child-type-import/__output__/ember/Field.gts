import type { TOC } from "@ember/component/template-only";

export interface FieldProps {
  name: string;
  label: string;
}

export interface FieldSignature {
  Args: FieldProps;
  Element: HTMLElementTagNameMap["label"];
}

const Field: TOC<FieldSignature> = <template><label ...attributes>{{@label}}<input name={{@name}}></label></template>;

export default Field;
