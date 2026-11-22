import Component from "@glimmer/component";
import { uniqueId } from "@ember/helper";

export interface FieldProps {
  label: string;
  hint: string;
}

export interface FieldSignature {
  Args: FieldProps;
  Element: HTMLElementTagNameMap["p"];
}

export default class Field extends Component<FieldSignature> {
  readonly inputId = `uf-id-${uniqueId()}`;

  readonly hintId = `uf-id-${uniqueId()}`;

  <template><p
      class="field"
      ...attributes
    ><label for={{this.inputId}}>{{@label}}</label><input
      id={{this.inputId}}
      type="text"
      aria-describedby={{this.hintId}}
    ><small id={{this.hintId}}>{{@hint}}</small></p></template>
}
