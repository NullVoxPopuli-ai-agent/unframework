import type { TOC } from "@ember/component/template-only";
import Field from "./Field.gts";

export interface FormSignature {
  Element: HTMLElementTagNameMap["form"];
}

const Form: TOC<FormSignature> = <template><form aria-label="Sign up" ...attributes><Field @label="Email" /><Field @label="Name" /></form></template>;

export default Form;
