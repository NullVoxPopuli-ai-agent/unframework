import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { capabilities, setModifierManager } from "@ember/modifier";
import type { ModifierLike } from "@glint/template";

export interface TagFormEvents {
  onTagsChange?: (tags: string[]) => void;
}

export interface TagFormSignature {
  Args: TagFormEvents;
  Element: HTMLElementTagNameMap["form"];
}

export default class TagForm extends Component<TagFormSignature> {
  blockComma = (event: KeyboardEvent) => {
    if (event.key === ",") event.preventDefault();
  };

  updateDraft = (event: InputEvent) => {
    this.draft = (event.currentTarget as HTMLInputElement).value;
  };

  addTag = (event: SubmitEvent) => {
    event.preventDefault();
    if (this.draft !== "" && !this.tags.includes(this.draft)) {
      this.tags = [...this.tags, this.draft];
      this.args.onTagsChange?.(this.tags);
    }
    this.draft = "";
    const input = this.field;
    if (input) input.value = "";
  };

  toggleHelp = (event: MouseEvent) => {
    event.preventDefault();
    this.helpOpen = !this.helpOpen;
  };

  @tracked tags: string[] = [];

  @tracked draft = "";

  @tracked helpOpen = false;

  @tracked field: HTMLInputElement | null = null;

  <template><form
      class="tag-form"
      aria-label="Tags"
      {{on "submit" this.addTag}}
      ...attributes
    ><label>New tag<input
      name="tag"
      {{templateRef this "field"}}
      {{on "keydown" this.blockComma}}
      {{on "input" this.updateDraft}}
    ></label><button type="submit">Add tag</button><a
      href="/help/tags"
      {{on "click" this.toggleHelp}}
    >How tags work</a>{{#if this.helpOpen}}<p>A tag is one word: commas are not allowed.</p>{{/if}}<ul
      aria-label="Added tags"
    >{{#each this.tags key="@identity" as |tag|}}<li>{{tag}}</li>{{/each}}</ul></form></template>
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
