import Component from "@glimmer/component";
import type { ButtonProps } from "./types";

export interface ButtonSignature {
  Args: ButtonProps;
  Element: HTMLElementTagNameMap["button"];
}

export default class Button extends Component<ButtonSignature> {
  get disabled() {
    return this.args.disabled === undefined ? false : this.args.disabled;
  }

  <template><button id={{@id}} type="button" disabled={{this.disabled}} ...attributes>{{@label}}</button></template>
}
