import type { TOC } from "@ember/component/template-only";
import "./Tag.uf.tsx.css";

export interface TagSignature {
  Args: { name: string };
  Element: HTMLElementTagNameMap["span"];
}

const Tag: TOC<TagSignature> = <template><span class="tag" data-uf-ef5e671c="" ...attributes>{{@name}}</span></template>;

export default Tag;
