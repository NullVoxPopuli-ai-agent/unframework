import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { capabilities, setModifierManager } from "@ember/modifier";
import type { ModifierLike } from "@glint/template";

export interface SearchToggleSignature {
  Element: HTMLElementTagNameMap["div"];
}

export default class SearchToggle extends Component<SearchToggleSignature> {
  focusField = () => {
    this.field?.focus();
  };

  returnFocus = (event: KeyboardEvent) => {
    if (event.key === "Escape") this.trigger?.focus();
  };

  @tracked field: HTMLInputElement | null = null;

  @tracked trigger: HTMLButtonElement | null = null;

  <template><div
      class="search-toggle"
      role="search"
      ...attributes
    ><button
      type="button"
      {{templateRef this "trigger"}}
      {{on "click" this.focusField}}
    >Search</button><input
      name="query"
      aria-label="Search the docs"
      {{templateRef this "field"}}
      {{on "keydown" this.returnFocus}}
    ></div></template>
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
