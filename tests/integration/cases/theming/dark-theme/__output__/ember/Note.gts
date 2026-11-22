import type { TOC } from "@ember/component/template-only";
import "virtual:styleframe.css";

export interface NoteSignature {
  Args: { text: string };
  Element: HTMLElementTagNameMap["p"];
}

const Note: TOC<NoteSignature> = <template><p class="_padding:md _background-color:surface _color:text" ...attributes>{{@text}}</p></template>;

export default Note;
