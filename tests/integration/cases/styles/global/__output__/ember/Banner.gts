import type { TOC } from "@ember/component/template-only";
import Hint from "./Hint.gts";
import "./Banner.uf.tsx.css";

export interface BannerSignature {
  Args: { tip: string };
  Element: HTMLElementTagNameMap["div"];
}

const Banner: TOC<BannerSignature> = <template><div
    class="banner"
    data-uf-e25060c2=""
    ...attributes
  ><Hint @text={{@tip}} data-uf-e25060c2="" /></div></template>;

export default Banner;
