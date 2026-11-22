import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface QuantityStepperProps {
  initial: number;
  label: string;
}

export interface QuantityStepperSignature {
  Args: QuantityStepperProps;
  Element: HTMLElementTagNameMap["div"];
}

export default class QuantityStepper extends Component<QuantityStepperSignature> {
  @tracked quantity = this.args.initial;

  get value1() {
    return `Increase ${this.args.label}`;
  }

  listener1 = () => this.quantity++;

  <template><div
      class="quantity-stepper"
      role="group"
      aria-label={{@label}}
      ...attributes
    ><output>{{this.quantity}}</output><button
      type="button"
      aria-label={{this.value1}}
      {{on "click" this.listener1}}
    >+</button></div></template>
}
