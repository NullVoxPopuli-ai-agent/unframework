import type { TOC } from "@ember/component/template-only";
import type { FieldOptions } from "./types";

export type TextFieldProps = Required<Pick<FieldOptions, "name" | "label">> &
  Readonly<Partial<Omit<FieldOptions, "name" | "label">>>;

export interface TextFieldSignature {
  Args: TextFieldProps;
  Element: HTMLElementTagNameMap["label"];
}

const TextField: TOC<TextFieldSignature> = <template><label
    ...attributes
  >{{@label}}<input name={{@name}} placeholder={{@placeholder}} required={{@required}}></label></template>;

export default TextField;
