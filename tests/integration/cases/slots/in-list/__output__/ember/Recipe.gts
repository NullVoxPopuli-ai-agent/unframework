import type { TOC } from "@ember/component/template-only";
import Steps from "./Steps.gts";

export interface RecipeSignature {
  Args: { steps: string[] };
  Element: HTMLElementTagNameMap["div"];
}

const Recipe: TOC<RecipeSignature> = <template><div
    ...attributes
  ><Steps @steps={{@steps}}><:marker><span aria-hidden="true">> </span></:marker></Steps></div></template>;

export default Recipe;
