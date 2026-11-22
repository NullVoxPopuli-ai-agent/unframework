import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { isDestroying, registerDestructor } from "@ember/destroyable";
import { renderSettled } from "@ember/renderer";

export interface UnreadBadgeProps {
  appName: string;
}

export interface UnreadBadgeEvents {
  onTitleChange?: (title: string) => void;
  onTitleRelease?: (title: string) => void;
}

export interface UnreadBadgeSignature {
  Args: UnreadBadgeProps & UnreadBadgeEvents;
  Element: HTMLElementTagNameMap["section"];
}

export default class UnreadBadge extends Component<UnreadBadgeSignature> {
  @tracked({ equals: Object.is }) unread = 0;

  readonly effect1 = new Effect(this, (onCleanup) => {
    const title = `(${this.unread}) ${this.args.appName}`;
    this.args.onTitleChange?.(title);
    onCleanup(() => {
      this.args.onTitleRelease?.(title);
    });
  });

  listener1 = () => this.unread++;

  listener2 = () => (this.unread = 0);

  <template><section
      class="unread-badge"
      aria-label="Inbox"
      ...attributes
    ><p role="status">{{this.unread}} unread</p><button
      type="button"
      {{on "click" this.listener1}}
    >Receive a message</button><button
      type="button"
      {{on "click" this.listener2}}
    >Mark all read</button></section>{{(this.effect1.flush)}}</template>
}

/**
 * Vue's `watchEffect`: the template calls `flush` after everything else, so the effect runs
 * once the component has rendered in the browser, and again when what it read changes. A
 * cleanup it registers runs before its next run, and when the component is destroyed.
 */
class Effect {
  @tracked ready = false;
  readonly #owner: object;
  readonly #effect: (onCleanup: (cleanup: () => void) => void) => unknown;
  #cleanup: (() => void) | undefined;

  constructor(owner: object, effect: (onCleanup: (cleanup: () => void) => void) => unknown) {
    this.#owner = owner;
    this.#effect = effect;
    registerDestructor(owner, () => this.#cleanup?.());
    void renderSettled().then(() => {
      if (!isDestroying(owner)) this.ready = true;
    });
  }

  readonly flush = (): undefined => {
    if (!this.ready) return undefined;
    // A watcher's callback is still to run after this render: the effect runs once after it,
    // and sees what it writes. Writing `ready` again renders this call again then.
    if (callbacks.pending) {
      queueMicrotask(() => {
        if (!isDestroying(this.#owner)) this.ready = true;
      });
      return undefined;
    }
    const cleanup = this.#cleanup;
    this.#cleanup = undefined;
    cleanup?.();
    void this.#effect((each) => {
      this.#cleanup = each;
    });
    return undefined;
  };
}

/** How many watchers' callbacks are to run once the current render is done. */
const callbacks = { pending: 0 };
