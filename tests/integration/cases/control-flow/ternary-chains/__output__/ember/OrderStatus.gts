import Component from "@glimmer/component";

export interface OrderStatusProps {
  status: "pending" | "shipped" | "delivered" | "cancelled";
  carrier?: string;
  eta?: string;
}

export interface OrderStatusSignature {
  Args: OrderStatusProps;
  Element: HTMLElementTagNameMap["p"];
}

export default class OrderStatus extends Component<OrderStatusSignature> {
  get value1() {
    return this.args.status === "pending";
  }

  get value2() {
    return this.args.status === "shipped";
  }

  get value3() {
    return this.args.status === "delivered";
  }

  get value4() {
    return this.args.carrier ?? "our courier";
  }

  get value5() {
    return this.args.eta ?? "soon";
  }

  <template><p
      class="order-status"
      ...attributes
    >{{#if this.value1}}Waiting for payment.{{else if this.value2}}<strong>Shipped</strong> with {{this.value4}}, arriving {{this.value5}}.{{else if this.value3}}<strong>Delivered</strong>{{else}}<em>Cancelled</em>{{/if}}</p></template>
}
