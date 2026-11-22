import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface InvoiceTotalProps {
  quantity: number;
}

export interface InvoiceTotalSignature {
  Args: InvoiceTotalProps;
  Element: HTMLElementTagNameMap["div"];
}

export default class InvoiceTotal extends Component<InvoiceTotalSignature> {
  refund = () => {
    this.refunded = this.refunded + 3;
  };

  @tracked refunded = 0;

  get total() {
    const units = this.args.quantity - this.refunded;
    if (units < 0) {
      throw new Error("The total is negative");
    }
    return units * 5;
  }

  get value1() {
    return `${this.total} after ${this.refunded} refunded`;
  }

  <template><div
      ...attributes
    ><output>{{this.value1}}</output><button
      type="button"
      {{on "click" this.refund}}
    >Refund</button></div></template>
}
