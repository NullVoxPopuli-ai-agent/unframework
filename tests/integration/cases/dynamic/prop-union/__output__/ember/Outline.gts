import type { TOC } from "@ember/component/template-only";
import Heading from "./Heading.gts";

export interface OutlineSignature {
  Element: HTMLElementTagNameMap["main"];
}

const Outline: TOC<OutlineSignature> = <template><main
    ...attributes
  ><Heading @tag="h1" @text="Guide" /><Heading @tag="h2" @text="Setup" /><Heading
    @tag="h3"
    @text="Requirements"
  /></main></template>;

export default Outline;
