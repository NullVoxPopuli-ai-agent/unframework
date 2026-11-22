import type { TOC } from "@ember/component/template-only";
import Frame from "./Frame.gts";

export interface GallerySignature {
  Element: HTMLElementTagNameMap["div"];
}

const Gallery: TOC<GallerySignature> = <template><div
    ...attributes
  ><Frame
    @label="Filled"
  ><:default><p>Taken at dusk.</p></:default><:title>Sunset</:title></Frame><Frame
    @label="Empty"
  /></div></template>;

export default Gallery;
