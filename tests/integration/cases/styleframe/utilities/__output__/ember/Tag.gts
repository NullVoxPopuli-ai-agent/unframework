import type { TOC } from "@ember/component/template-only";
import "virtual:styleframe.css";

export interface TagSignature {
  Args: { label: string };
  Element: HTMLElementTagNameMap["span"];
}

const Tag: TOC<TagSignature> = <template><span
    class="_padding:lg _background-color:primary _color:on-primary _border-radius:[4px]"
    ...attributes
  >{{@label}}</span></template>;

export default Tag;
