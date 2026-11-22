import type { TOC } from "@ember/component/template-only";
import Button from "./Button.gts";
import "./Toolbar.uf.tsx.css";

export interface ToolbarSignature {
  Element: HTMLElementTagNameMap["div"];
}

const Toolbar: TOC<ToolbarSignature> = <template><div
    role="toolbar"
    aria-label="Actions"
    class="toolbar"
    data-uf-a33d603f=""
    ...attributes
  ><Button @text="Save" data-uf-a33d603f="" /><Button @text="Cancel" data-uf-a33d603f="" /></div></template>;

export default Toolbar;
