import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface NoteEditorEvents {
  onSaved?: (title: string, bold: boolean) => void;
}

export interface NoteEditorSignature {
  Args: NoteEditorEvents;
  Element: HTMLElementTagNameMap["form"];
}

export default class NoteEditor extends Component<NoteEditorSignature> {
  save = () => {
    this.saves += 1;
    this.args.onSaved?.(this.title, this.bold);
  };

  @tracked title = "";

  @tracked bold = false;

  @tracked saves = 0;

  listener1 = (event: HTMLElementEventMap["input"]) =>
    (this.title = (event.currentTarget as HTMLInputElement).value);

  listener2 = (event: HTMLElementEventMap["mousedown"]) => event.preventDefault();

  listener3 = () => (this.bold = !this.bold);

  listener4 = (event: HTMLElementEventMap["submit"]) => event.preventDefault();

  <template><form
      class="note-editor"
      aria-label="Note"
      {{on "submit" this.listener4}}
      ...attributes
    ><label>Title<input name="title" {{on "input" this.listener1}}></label><label>Text<textarea
      name="text"
    ></textarea></label><div
      class="format"
      role="group"
      aria-label="Format"
    ><button
      type="button"
      aria-pressed={{enumeratedValue this.bold}}
      {{on "mousedown" this.listener2}}
      {{on "click" this.listener3}}
    >Bold</button></div><button type="submit" {{on "click" this.save}}>Save</button><p
      role="status"
    >Saves: {{this.saves}}</p></form></template>
}

/** An enumerated attribute's value: a boolean as its name, any other value as it is. */
function enumeratedValue<T>(value: T): Exclude<T, boolean> | "true" | "false" {
  return typeof value === "boolean"
    ? (String(value) as "true" | "false")
    : (value as Exclude<T, boolean>);
}
