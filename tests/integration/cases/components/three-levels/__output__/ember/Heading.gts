import type { TOC } from "@ember/component/template-only";

export interface HeadingSignature {
  Args: { text: string };
  Element: HTMLElementTagNameMap["h3"];
}

const Heading: TOC<HeadingSignature> = <template><h3 class="heading" ...attributes>{{@text}}</h3></template>;

export default Heading;
