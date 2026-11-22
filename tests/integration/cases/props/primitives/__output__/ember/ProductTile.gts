import Component from "@glimmer/component";

export interface ProductTileProps {
  name: string;
  price: number;
  stock: number;
  available?: boolean;
}

export interface ProductTileSignature {
  Args: ProductTileProps;
  Element: HTMLElementTagNameMap["article"];
}

export default class ProductTile extends Component<ProductTileSignature> {
  get available() {
    return this.args.available === undefined ? true : this.args.available;
  }

  get value1() {
    return this.available ? "Available to order" : "Currently unavailable";
  }

  get value2() {
    return !this.available;
  }

  <template><article
      class="product-tile"
      aria-label={{@name}}
      ...attributes
    ><h2>{{@name}}</h2><p>Price: {{@price}} EUR</p><p data-stock={{@stock}}>{{@stock}} in stock</p><p>{{this.value1}}</p><button
      type="button"
      disabled={{this.value2}}
    >Add {{@name}} to basket</button></article></template>
}
