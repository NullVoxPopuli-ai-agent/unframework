import Component from "@glimmer/component";
import { uniqueId } from "@ember/helper";

export interface EmailFieldProps {
  label: string;
  hint: string;
}

export interface EmailFieldSignature {
  Args: EmailFieldProps;
  Element: HTMLElementTagNameMap["div"];
}

export default class EmailField extends Component<EmailFieldSignature> {
  readonly inputId = `uf-id-${uniqueId()}`;

  readonly hintId = `uf-id-${uniqueId()}`;

  <template><div
      class="email-field"
      ...attributes
    ><label for={{this.inputId}}>{{@label}}</label><input
      id={{this.inputId}}
      name="email"
      type="email"
      aria-describedby={{this.hintId}}
    ><p id={{this.hintId}}>{{@hint}}</p></div></template>
}
