import type { TOC } from "@ember/component/template-only";
import Badge from "./Badge.gts";
import Tag from "./Tag.gts";

export interface LabelsSignature {
  Element: HTMLElementTagNameMap["section"];
}

const Labels: TOC<LabelsSignature> = <template><section
    class="labels"
    aria-label="Labels"
    ...attributes
  ><Badge @label="New" /><Tag @name="docs" /></section></template>;

export default Labels;
