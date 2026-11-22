import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { formatPrice, pluralise } from "./format";

export interface PriceTagEvents {
  onOrder?: (summary: string) => void;
}

export interface PriceTagSignature {
  Args: { cents: number } & PriceTagEvents;
  Element: HTMLElementTagNameMap["section"];
}

export default class PriceTag extends Component<PriceTagSignature> {
  order = () => {
    this.args.onOrder?.(`${pluralise(this.quantity, "item")} for ${this.total}`);
  };

  @tracked quantity = 1;

  get total() {
    return formatPrice(this.args.cents * this.quantity);
  }

  get value1() {
    return formatPrice(this.args.cents);
  }

  get value2() {
    return pluralise(this.quantity, "item");
  }

  listener1 = () => this.quantity++;

  <template><section
      class="price-tag"
      aria-label="Price"
      ...attributes
    ><p>Each: {{this.value1}}</p><p role="status">{{this.value2}}: {{this.total}}</p><button
      type="button"
      {{on "click" this.listener1}}
    >One more</button><button type="button" {{on "click" this.order}}>Order</button></section></template>
}
