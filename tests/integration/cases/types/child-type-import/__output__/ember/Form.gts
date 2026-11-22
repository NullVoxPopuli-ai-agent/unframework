import type { TOC } from "@ember/component/template-only";
import Field, { type FieldProps } from "./Field.gts";

export interface FormSignature {
  Args: { field: FieldProps };
  Element: HTMLElementTagNameMap["form"];
}

const Form: TOC<FormSignature> = <template><form
    aria-label="Sign up"
    ...attributes
  ><Field @name={{@field.name}} @label={{@field.label}} /></form></template>;

export default Form;
