import type { TOC } from "@ember/component/template-only";

export interface PanelSignature {
  Args: { title: string };
  Blocks: { default: [] };
  Element: HTMLElementTagNameMap["section"];
}

const Panel: TOC<PanelSignature> = <template><section
    class="panel"
    aria-label={{@title}}
    ...attributes
  ><h2>{{@title}}</h2>{{yield}}</section></template>;

export default Panel;
