import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { isDestroying } from "@ember/destroyable";
import { capabilities, setModifierManager } from "@ember/modifier";
import { renderSettled } from "@ember/renderer";
import type { ModifierLike } from "@glint/template";

export interface ArticlePreviewProps {
  title: string;
  text: string;
}

export interface ArticlePreviewEvents {
  onReady?: (characters: number) => void;
}

export interface ArticlePreviewSignature {
  Args: ArticlePreviewProps & ArticlePreviewEvents;
  Element: HTMLElementTagNameMap["article"];
}

export default class ArticlePreview extends Component<ArticlePreviewSignature> {
  @tracked body: HTMLParagraphElement | null = null;

  @tracked characters = 0;

  @tracked counted = false;

  #mounted = false;

  /** Called at the template's end: the hooks run once the component has rendered. */
  onMounted = (): undefined => {
    if (!this.#mounted) {
      this.#mounted = true;
      afterRender(this, () => {
        const length = this.body?.textContent?.length ?? 0;
        this.characters = length;
        this.counted = true;
        this.args.onReady?.(length);
      });
    }
    return undefined;
  };

  get value1() {
    return this.counted ? `${this.characters} characters` : "Counting the characters";
  }

  <template><article
      class="article-preview"
      aria-label={{@title}}
      ...attributes
    ><h2>{{@title}}</h2><p {{templateRef this "body"}}>{{@text}}</p><p
      role="status"
    >{{this.value1}}</p></article>{{(this.onMounted)}}</template>
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
