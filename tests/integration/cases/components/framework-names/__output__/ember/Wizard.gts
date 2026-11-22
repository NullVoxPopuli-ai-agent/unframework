import type { TOC } from "@ember/component/template-only";
import KeepAlive from "./KeepAlive.gts";
import Transition from "./Transition.gts";
import TransitionComponent from "./TransitionComponent.gts";

export interface WizardSignature {
  Element: HTMLElementTagNameMap["section"];
}

const Wizard: TOC<WizardSignature> = <template><section
    aria-label="Wizard"
    ...attributes
  ><Transition @step="details" /><TransitionComponent /><KeepAlive @level={{2}} /></section></template>;

export default Wizard;
