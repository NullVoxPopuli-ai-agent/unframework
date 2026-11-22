import type { TOC } from "@ember/component/template-only";
import Heading from "./Heading.gts";
import Status from "./Status.gts";
import "./Panel.uf.tsx.css";

export interface PanelSignature {
  Element: HTMLElementTagNameMap["section"];
}

const Panel: TOC<PanelSignature> = <template><section
    class="panel"
    data-uf-34db6205=""
    ...attributes
  ><Heading @big={{true}} @text="Release" data-uf-34db6205="" /><Heading
    @big={{false}}
    @text="Notes"
    data-uf-34db6205=""
  /><Status @busy={{false}} @text="Save" data-uf-34db6205="" /><Status
    @busy={{true}}
    @text="Save"
    data-uf-34db6205=""
  /></section></template>;

export default Panel;
