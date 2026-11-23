import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { isDestroying } from "@ember/destroyable";
import { uniqueId } from "@ember/helper";
import { capabilities, setModifierManager } from "@ember/modifier";
import { renderSettled } from "@ember/renderer";
import type { ModifierLike } from "@glint/template";

export interface ConfirmDialogProps {
  title: string;
}

export interface ConfirmDialogEvents {
  onConfirm?: () => void;
  onClose?: () => void;
}

export interface ConfirmDialogSignature {
  Args: ConfirmDialogProps & ConfirmDialogEvents;
  Element: HTMLElementTagNameMap["div"];
}

export default class ConfirmDialog extends Component<ConfirmDialogSignature> {
  onKeydown = (event: KeyboardEvent) => {
    if (event.key === "Escape") this.args.onClose?.();
  };

  readonly titleId = `uf-id-${uniqueId()}`;

  @tracked cancel: HTMLButtonElement | null = null;

  #mounted = false;

  /** Called at the template's end: the hooks run once the component has rendered. */
  onMounted = (): undefined => {
    if (!this.#mounted) {
      this.#mounted = true;
      afterRender(this, () => {
        this.cancel?.focus();
      });
    }
    return undefined;
  };

  listener1 = () => this.args.onClose?.();

  listener2 = () => this.args.onConfirm?.();

  <template><div
      role="dialog"
      aria-modal="true"
      aria-labelledby={{this.titleId}}
      tabindex="-1"
      class="dialog"
      {{on "keydown" this.onKeydown}}
      ...attributes
    ><h2 id={{this.titleId}}>{{@title}}</h2><button
      type="button"
      {{templateRef this "cancel"}}
      {{on "click" this.listener1}}
    >Cancel</button><button type="button" {{on "click" this.listener2}}>Delete</button></div>{{(this.onMounted)}}</template>
}

/** Runs `run` once the render settles, unless its component is gone by then. */
function afterRender(owner: object, run: () => unknown): void {
  // A component on the server never mounts, as Vue registers no hook in a server render.
  if (import.meta.env.SSR) return;
  void renderSettled().then(() => {
    if (!isDestroying(owner)) void run();
  });
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
