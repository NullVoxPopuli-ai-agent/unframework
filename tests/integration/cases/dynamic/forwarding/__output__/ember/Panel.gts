import type { TOC } from "@ember/component/template-only";

export interface PanelSignature {
  Blocks: { title: [] };
  Element: HTMLElementTagNameMap["div"];
}

const Panel: TOC<PanelSignature> = <template><div
    class="panel"
    ...attributes
  ><h4>{{#if (has-block "title")}}{{yield to="title"}}{{else}}Untitled{{/if}}</h4></div></template>;

export default Panel;
