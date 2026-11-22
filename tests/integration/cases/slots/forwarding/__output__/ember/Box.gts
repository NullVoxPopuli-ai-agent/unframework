import type { TOC } from "@ember/component/template-only";

export interface BoxSignature {
  Blocks: { title: []; default: [] };
  Element: HTMLElementTagNameMap["div"];
}

const Box: TOC<BoxSignature> = <template><div
    class="box"
    ...attributes
  ><h3>{{#if (has-block "title")}}{{yield to="title"}}{{else}}Untitled{{/if}}</h3>{{#if (has-block)}}{{yield}}{{else}}<p>No content</p>{{/if}}</div></template>;

export default Box;
