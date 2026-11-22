import type { TOC } from "@ember/component/template-only";

export interface ReviewSummaryProps {
  steps: string[];
  score: number;
  sku: string;
  product: string;
}

export interface ReviewSummarySignature {
  Args: ReviewSummaryProps;
  Element: HTMLElementTagNameMap["section"];
}

const ReviewSummary: TOC<ReviewSummarySignature> = <template><section
    class="review-summary"
    aria-label="Review"
    ...attributes
  ><ol>{{#each @steps key="@identity" as |step index|}}<li value={{index}}>{{step}}</li>{{/each}}</ol><meter
    min="0"
    max="10"
    value={{@score}}
    aria-label="Score"
  >{{@score}} out of 10</meter><p>Product: <data value={{@sku}}>{{@product}}</data></p></section></template>;

export default ReviewSummary;
