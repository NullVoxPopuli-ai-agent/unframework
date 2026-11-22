import type { TOC } from "@ember/component/template-only";
import "./Panel.uf.tsx.css";

export interface PanelSignature {
  Args: { text: string };
  Element: HTMLElementTagNameMap["aside"];
}

const Panel: TOC<PanelSignature> = <template><aside
    class="panel"
    data-uf-48dda3f4=""
    ...attributes
  ><p class="text" data-uf-48dda3f4="">{{@text}}</p></aside></template>;

export default Panel;
