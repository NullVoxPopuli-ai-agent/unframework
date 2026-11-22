import type { TOC } from "@ember/component/template-only";
import Swatch from "./Swatch.gts";
import type { Tone } from "./types";

export type { Tone } from "./types";

export interface PaletteSignature {
  Args: { tone: Tone };
  Element: HTMLElementTagNameMap["div"];
}

const Palette: TOC<PaletteSignature> = <template><div class="palette" ...attributes><Swatch @tone={{@tone}} /></div></template>;

export default Palette;
