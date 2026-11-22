import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface OrderSummaryProps {
  /** The unit price, in cents. */
  price: number;
  taxRate: number;
}

export interface OrderSummarySignature {
  Args: OrderSummaryProps;
  Element: HTMLElementTagNameMap["section"];
}

export default class OrderSummary extends Component<OrderSummarySignature> {
  @tracked quantity = 1;

  get subtotal() {
    return this.quantity * this.args.price;
  }

  get tax() {
    return Math.round(this.subtotal * this.args.taxRate);
  }

  get total() {
    return this.subtotal + this.tax;
  }

  get tier() {
    if (this.total >= 10000) return "bulk";
    return "standard";
  }

  get value1() {
    return this.quantity === 1;
  }

  listener1 = () => this.quantity--;

  listener2 = () => this.quantity++;

  get value2() {
    return (this.subtotal / 100).toFixed(2);
  }

  get value3() {
    return (this.tax / 100).toFixed(2);
  }

  get value4() {
    return (this.total / 100).toFixed(2);
  }

  <template><section
      class="order-summary"
      aria-label="Order summary"
      data-tier={{this.tier}}
      ...attributes
    ><p role="status">Quantity: {{this.quantity}}</p><button
      type="button"
      disabled={{this.value1}}
      {{on "click" this.listener1}}
    >Remove one</button><button type="button" {{on "click" this.listener2}}>Add one</button><p>Subtotal: {{this.value2}}</p><p>Tax: {{this.value3}}</p><p>Total: {{this.value4}}</p></section></template>
}
