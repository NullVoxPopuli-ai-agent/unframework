import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { isDestroying, registerDestructor } from "@ember/destroyable";
import { capabilities, setModifierManager } from "@ember/modifier";
import { renderSettled } from "@ember/renderer";
import type { ModifierLike } from "@glint/template";

export interface ProfileMenuEvents {
  onClosed?: () => void;
}

export interface ProfileMenuSignature {
  Args: ProfileMenuEvents;
  Element: HTMLElementTagNameMap["section"];
}

export default class ProfileMenu extends Component<ProfileMenuSignature> {
  onDocumentClick = (event: MouseEvent) => {
    const element = this.menu;
    if (this.open && element && !element.contains(event.target as Node)) {
      this.open = false;
      this.args.onClosed?.();
    }
  };

  @tracked open = false;

  @tracked menu: HTMLDivElement | null = null;

  #mounted = false;

  /** Called at the template's end: the hooks run once the component has rendered. */
  onMounted = (): undefined => {
    if (!this.#mounted) {
      this.#mounted = true;
      afterRender(this, () => {
        document.addEventListener("click", this.onDocumentClick);
      });
      afterRender(this, () =>
        registerDestructor(this, () => {
          document.removeEventListener("click", this.onDocumentClick);
        }),
      );
    }
    return undefined;
  };

  listener1 = () => (this.open = !this.open);

  <template><section
      class="profile-menu"
      aria-label="Profile"
      ...attributes
    ><div
      class="menu"
      {{templateRef this "menu"}}
    ><button
      type="button"
      aria-expanded={{enumeratedValue this.open}}
      {{on "click" this.listener1}}
    >Account</button>{{#if this.open}}<ul
      aria-label="Account actions"
    ><li><button type="button">Settings</button></li><li><button type="button">Sign out</button></li></ul>{{/if}}</div><p>Outside the menu</p></section>{{(this.onMounted)}}</template>
}

/** Runs `run` once the render settles, unless its component is gone by then. */
function afterRender(owner: object, run: () => unknown): void {
  // A component on the server never mounts, as Vue registers no hook in a server render.
  if (import.meta.env.SSR) return;
  void renderSettled().then(() => {
    if (!isDestroying(owner)) void run();
  });
}

/** An enumerated attribute's value: a boolean as its name, any other value as it is. */
function enumeratedValue<T>(value: T): Exclude<T, boolean> | "true" | "false" {
  return typeof value === "boolean"
    ? (String(value) as "true" | "false")
    : (value as Exclude<T, boolean>);
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
