import type { TOC } from "@ember/component/template-only";
import "virtual:styleframe.css";
import "./Panel.uf.tsx.css";

export interface PanelSignature {
  Args: { text: string };
  Element: HTMLElementTagNameMap["section"];
}

const Panel: TOC<PanelSignature> = <template><section
    class="panel"
    data-uf-b6be1fd3=""
    ...attributes
  ><p class="body" data-uf-b6be1fd3="">{{@text}}</p></section></template>;

export default Panel;
