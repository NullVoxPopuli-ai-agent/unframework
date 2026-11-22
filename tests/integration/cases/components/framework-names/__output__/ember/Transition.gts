import type { TOC } from "@ember/component/template-only";

export interface TransitionSignature {
  Args: { step: string };
  Element: HTMLElementTagNameMap["p"];
}

const Transition: TOC<TransitionSignature> = <template><p class="step" ...attributes>Step: {{@step}}</p></template>;

export default Transition;
