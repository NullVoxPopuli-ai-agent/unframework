import type { TOC } from "@ember/component/template-only";
import Heading from "./Heading.gts";

export interface SectionSignature {
  Args: { title: string; body: string };
  Element: HTMLElementTagNameMap["section"];
}

const Section: TOC<SectionSignature> = <template><section class="section" ...attributes><Heading @text={{@title}} /><p>{{@body}}</p></section></template>;

export default Section;
