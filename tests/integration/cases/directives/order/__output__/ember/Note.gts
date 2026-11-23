import type { TOC } from "@ember/component/template-only";
import { vNote } from "./vNote.ts";

export interface NoteSignature {
  Element: HTMLElementTagNameMap["em"];
}

const Note: TOC<NoteSignature> = <template><em data-name="note" {{vNote "note"}} ...attributes>Note</em></template>;

export default Note;
