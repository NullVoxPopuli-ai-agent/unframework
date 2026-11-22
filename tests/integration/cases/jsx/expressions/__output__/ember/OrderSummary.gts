import Component from "@glimmer/component";

export interface OrderSummaryProps {
  customer: string;
  orderNumber: number;
  unitPrice: number;
  quantity: number;
  discount: number;
  coupon?: string;
}

export interface OrderSummarySignature {
  Args: OrderSummaryProps;
  Element: HTMLElementTagNameMap["section"];
}

export default class OrderSummary extends Component<OrderSummarySignature> {
  get value1() {
    return String(this.args.orderNumber).padStart(6, "0");
  }

  get value2() {
    return this.args.customer.trim().toUpperCase();
  }

  get value3() {
    return `${this.args.quantity} item${this.args.quantity === 1 ? "" : "s"} at ${this.args.unitPrice.toFixed(2)} each`;
  }

  get value4() {
    return (this.args.unitPrice * this.args.quantity).toFixed(2);
  }

  get value5() {
    return Math.min(Math.max(this.args.discount, 0), 50);
  }

  get value6() {
    return (
      this.args.unitPrice *
      this.args.quantity *
      (1 - Math.min(Math.max(this.args.discount, 0), 50) / 100)
    ).toFixed(2);
  }

  get value7() {
    return this.args.quantity > 10 ? "Bulk order" : "Standard order";
  }

  get value8() {
    return this.args.coupon ? "coupon applied" : "no coupon";
  }

  get value9() {
    return Math.round(this.args.unitPrice * this.args.quantity) % 100;
  }

  <template><section
      class="order-summary"
      aria-label="Order summary"
      ...attributes
    ><h2>Order {{this.value1}}</h2><p>Customer: {{this.value2}}</p><p>{{this.value3}}</p><p>Subtotal: {{this.value4}}</p><p>Discount: {{this.value5}}%</p><p>Total: {{this.value6}}</p><p>{{this.value7}}, {{this.value8}}</p><p>Points earned: {{this.value9}}</p></section></template>
}
