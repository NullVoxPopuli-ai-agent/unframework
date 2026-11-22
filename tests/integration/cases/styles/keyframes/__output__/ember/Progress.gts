import type { TOC } from "@ember/component/template-only";
import "./Progress.uf.tsx.css";

export interface ProgressSignature {
  Args: { label: string };
  Element: HTMLElementTagNameMap["div"];
}

const Progress: TOC<ProgressSignature> = <template><div
    class="progress"
    data-uf-0738d8af=""
    ...attributes
  ><span class="dot" data-uf-0738d8af=""></span><span data-uf-0738d8af="">{{@label}}</span></div></template>;

export default Progress;
