import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface NoteEditorSignature {
  Element: HTMLElementTagNameMap["section"];
}

export default class NoteEditor extends Component<NoteEditorSignature> {
  @tracked note = "Buy milk";

  listener1 = (event: Event) => {
    this.note = (event.currentTarget as HTMLTextAreaElement).value;
  };

  listener2 = () => (this.note = "");

  <template><section
      aria-label="Note"
      ...attributes
    ><textarea aria-label="Text" value={{this.note}} {{on "input" this.listener1}}></textarea><output>{{this.note.length}} characters</output><button
      type="button"
      {{on "click" this.listener2}}
    >Discard</button></section></template>
}
