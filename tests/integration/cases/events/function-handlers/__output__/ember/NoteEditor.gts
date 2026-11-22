import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { capabilities, setModifierManager } from "@ember/modifier";
import type { ModifierLike } from "@glint/template";

export interface NoteEditorEvents {
  onSaved?: (count: number) => void;
  onTagged?: (tag: string, via: string) => void;
}

export interface NoteEditorSignature {
  Args: NoteEditorEvents;
  Element: HTMLElementTagNameMap["section"];
}

export default class NoteEditor extends Component<NoteEditorSignature> {
  save = () => {
    this.saves += 1;
    this.args.onSaved?.(this.saves);
  };

  recordKey = (event: KeyboardEvent) => {
    this.lastKey = event.key;
  };

  addTag = (event: MouseEvent | KeyboardEvent) => {
    if (this.tag === "") return;
    this.tags = [...this.tags, this.tag];
    this.args.onTagged?.(this.tag, event.type);
    this.tag = "";
    if (this.tagField) this.tagField.value = "";
  };

  onTagKeydown = (event: KeyboardEvent) => {
    if (event.key === "Enter") this.addTag(event);
  };

  @tracked saves = 0;

  @tracked lastKey = "none";

  @tracked tags: string[] = [];

  @tracked tag = "";

  @tracked tagField: HTMLInputElement | null = null;

  listener1 = (event: HTMLElementEventMap["input"]) =>
    (this.tag = (event.currentTarget as HTMLInputElement).value);

  get value1() {
    return this.tags.join(", ");
  }

  <template><section
      class="note-editor"
      aria-label="Note"
      ...attributes
    ><button type="button" {{on "click" this.save}}>Save</button><label>Title<input
      name="title"
      {{on "keydown" this.recordKey}}
    ></label><label>Body<textarea name="body" {{on "keydown" this.recordKey}}></textarea></label><p
      role="status"
    >Saved {{this.saves}} times, last key {{this.lastKey}}</p><button
      type="button"
      {{on "click" this.save}}
    >Save and close</button><label>Tag<input
      {{templateRef this "tagField"}}
      name="tag"
      {{on "input" this.listener1}}
      {{on "keydown" this.onTagKeydown}}
    ></label><button type="button" {{on "click" this.addTag}}>Add tag</button><p>Tags: {{this.value1}}</p></section></template>
}

/** A modifier that sets a member of its component to its element while the element is rendered. */
const templateRef = setModifierManager(
  () => ({
    capabilities: capabilities("3.22"),
    createModifier: () => ({}),
    installModifier(
      _state: object,
      element: Element,
      { positional }: { positional: readonly unknown[] },
    ) {
      Reflect.set(positional[0] as object, positional[1] as string, element);
    },
    updateModifier() {},
    destroyModifier(_state: object, { positional }: { positional: readonly unknown[] }) {
      Reflect.set(positional[0] as object, positional[1] as string, null);
    },
  }),
  {},
) as unknown as ModifierLike<{
  Element: Element;
  Args: { Positional: [owner: object, name: string] };
}>;
