import type { TOC } from "@ember/component/template-only";

export interface TagSignature {
  Args: { label: string };
  Element: HTMLElementTagNameMap["span"];
}

const Tag: TOC<TagSignature> = <template><span
    class="tag"
    style="padding: 2px 6px; color: rgb(30, 30, 30)"
    ...attributes
  >{{@label}}</span></template>;

export default Tag;
