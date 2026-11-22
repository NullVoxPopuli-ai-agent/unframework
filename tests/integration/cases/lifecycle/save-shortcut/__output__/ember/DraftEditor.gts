import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { isDestroying, registerDestructor } from "@ember/destroyable";
import { renderSettled } from "@ember/renderer";

export interface DraftEditorEvents {
  onSaved?: (count: number) => void;
}

export interface DraftEditorSignature {
  Args: DraftEditorEvents;
  Element: HTMLElementTagNameMap["section"];
}

export default class DraftEditor extends Component<DraftEditorSignature> {
  onShortcut = (event: KeyboardEvent) => {
    if (event.key !== "s" || !event.ctrlKey) return;
    event.preventDefault();
    this.saves += 1;
    this.args.onSaved?.(this.saves);
  };

  @tracked saves = 0;

  #mounted = false;

  /** Called at the template's end: the hooks run once the component has rendered. */
  onMounted = (): undefined => {
    if (!this.#mounted) {
      this.#mounted = true;
      afterRender(this, () => {
        document.addEventListener("keydown", this.onShortcut);
      });
      afterRender(this, () =>
        registerDestructor(this, () => {
          document.removeEventListener("keydown", this.onShortcut);
        }),
      );
    }
    return undefined;
  };

  <template><section
      class="draft-editor"
      aria-label="Draft"
      ...attributes
    ><label>Draft<textarea name="draft"></textarea></label><p
      role="status"
    >Saved: {{this.saves}}</p></section>{{(this.onMounted)}}</template>
}

/** Runs `run` once the render settles, unless its component is gone by then. */
function afterRender(owner: object, run: () => unknown): void {
  void renderSettled().then(() => {
    if (!isDestroying(owner)) void run();
  });
}
