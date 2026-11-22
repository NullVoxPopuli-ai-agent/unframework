import type { TOC } from "@ember/component/template-only";

interface FieldAttributes {
  name: string;
  placeholder?: string;
  autocomplete?: "email" | "username";
  maxlength?: number;
  required?: boolean;
  title?: string;
}

interface HintAttributes {
  id: string;
  title?: string;
}

export interface TextFieldProps {
  label: string;
  inputId: string;
  hintText: string;
  field: FieldAttributes;
  hint?: HintAttributes;
}

export interface TextFieldSignature {
  Args: TextFieldProps;
  Element: HTMLElementTagNameMap["div"];
}

const TextField: TOC<TextFieldSignature> = <template><div
    class="text-field"
    ...attributes
  ><label for={{@inputId}}>{{@label}}</label><input
    id={{@inputId}}
    type="text"
    name={{@field.name}}
    placeholder={{@field.placeholder}}
    autocomplete={{@field.autocomplete}}
    maxlength={{@field.maxlength}}
    required={{@field.required}}
    title={{@field.title}}
  ><p class="text-field-hint" id={{@hint.id}} title={{@hint.title}}>{{@hintText}}</p></div></template>;

export default TextField;
