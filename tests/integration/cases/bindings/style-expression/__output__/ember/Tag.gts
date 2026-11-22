import type { TOC } from "@ember/component/template-only";

export interface TagProps {
  label: string;
  tone?: string;
}

export interface TagSignature {
  Args: TagProps;
  Element: HTMLElementTagNameMap["em"];
}

const Tag: TOC<TagSignature> = <template><em class="tag" style="color: rgb(120, 30, 30); padding: 1px 4px" ...attributes>{{@label}}</em></template>;

export default Tag;
