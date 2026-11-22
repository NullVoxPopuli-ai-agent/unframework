import type { TOC } from "@ember/component/template-only";

export interface NoteSignature {
  Args: { text: string };
  Element: HTMLElementTagNameMap["div"];
}

const Note: TOC<NoteSignature> = <template><div class="note-box" ...attributes><p class="note">{{@text}}</p></div></template>;

export default Note;
