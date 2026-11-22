import type { TOC } from "@ember/component/template-only";
import Level from "./Level.gts";

export interface OutlineSignature {}

const Outline: TOC<OutlineSignature> = <template><Level
    @title="Book"
  ><Level @title="Part"><Level @title="Chapter" /></Level><Level @title="Appendix" /></Level></template>;

export default Outline;
