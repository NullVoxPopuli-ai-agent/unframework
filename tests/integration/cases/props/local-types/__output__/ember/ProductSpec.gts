import type { TOC } from "@ember/component/template-only";

type Availability = "in-stock" | "backorder" | "discontinued";

interface Finish {
  sku: string;
  label: string;
}

export interface ProductSpecProps {
  name: string;
  availability: Availability;
  size: { width: number; depth: number; unit: "cm" | "in" };
  finishes: Finish[];
}

export interface ProductSpecSignature {
  Args: ProductSpecProps;
  Element: HTMLElementTagNameMap["section"];
}

const ProductSpec: TOC<ProductSpecSignature> = <template><section
    class="product-spec"
    aria-label={{@name}}
    ...attributes
  ><h2>{{@name}}</h2><dl><dt>Availability</dt><dd>{{@availability}}</dd><dt>Size</dt><dd>{{@size.width}} × {{@size.depth}} {{@size.unit}}</dd></dl><ul>{{#each @finishes key="sku" as |finish|}}<li>{{finish.label}} ({{finish.sku}})</li>{{/each}}</ul></section></template>;

export default ProductSpec;
