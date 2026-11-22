import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { renderSettled } from "@ember/renderer";

export interface SaveDraftEvents {
  onSaved?: (attempt: number, status: string) => void;
}

export interface SaveDraftSignature {
  Args: SaveDraftEvents;
  Element: HTMLElementTagNameMap["section"];
}

export default class SaveDraft extends Component<SaveDraftSignature> {
  save = async () => {
    this.status = "Saving";
    this.attempts += 1;
    await Promise.resolve();
    this.status = "Checking";
    await renderSettled();
    this.status = `Saved, attempt ${this.attempts}`;
    this.args.onSaved?.(this.attempts, this.status);
  };

  @tracked status = "Not saved";

  @tracked attempts = 0;

  <template><section
      class="save-draft"
      aria-label="Draft"
      ...attributes
    ><p role="status">{{this.status}}</p><button
      type="button"
      {{on "click" this.save}}
    >Save the draft</button></section></template>
}
