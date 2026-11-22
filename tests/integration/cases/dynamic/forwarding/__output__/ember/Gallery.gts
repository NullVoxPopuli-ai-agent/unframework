import type { TOC } from "@ember/component/template-only";
import Frame from "./Frame.gts";

export interface GallerySignature {
  Element: HTMLElementTagNameMap["div"];
}

const Gallery: TOC<GallerySignature> = <template><div
    ...attributes
  ><Frame @label="Card" @wide={{false}}><:title>Sunset</:title></Frame><Frame
    @label="Panel"
    @wide={{true}}
  ><:title>Dawn</:title></Frame><Frame @label="Empty" @wide={{true}} /></div></template>;

export default Gallery;
