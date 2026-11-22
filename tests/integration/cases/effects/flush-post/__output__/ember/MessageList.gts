import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { isDestroying, registerDestructor } from "@ember/destroyable";
import { capabilities, setModifierManager } from "@ember/modifier";
import { renderSettled } from "@ember/renderer";
import type { ModifierLike } from "@glint/template";

export interface MessageListEvents {
  onRendered?: (count: number) => void;
}

export interface MessageListSignature {
  Args: MessageListEvents;
  Element: HTMLElementTagNameMap["section"];
}

export default class MessageList extends Component<MessageListSignature> {
  add = () => {
    this.messages = [...this.messages, `Message ${this.messages.length + 1}`];
  };

  @tracked messages = ["Welcome to the team"];

  @tracked list: HTMLUListElement | null = null;

  readonly watcher1 = new Watcher(
    this,
    () => this.messages,
    () => {
      this.args.onRendered?.(this.list?.childElementCount ?? 0);
    },
    { post: true },
  );

  <template>{{(this.watcher1.flush)}}<section
      class="message-list"
      aria-label="Messages"
      ...attributes
    ><ul
      {{templateRef this "list"}}
    >{{#each this.messages key="@identity" as |message|}}<li>{{message}}</li>{{/each}}</ul><button
      type="button"
      {{on "click" this.add}}
    >Add a message</button></section></template>
}

/**
 * Vue's `watch`: the template calls `flush` before anything else, so it sees a change of a
 * source in the render that follows it, and the callback runs right after that render, or once
 * the render settles for a `post` watcher. A cleanup the callback registers runs before its
 * next run, and when the component is destroyed.
 */
class Watcher<T> {
  readonly #owner: object;
  readonly #source: () => T;
  readonly #callback: (value: T, previous: T, onCleanup: (cleanup: () => void) => void) => unknown;
  readonly #options: { array?: boolean; immediate?: boolean; post?: boolean };
  #started = false;
  #value: T | undefined;
  #cleanup: (() => void) | undefined;

  constructor(
    owner: object,
    source: () => T,
    callback: (value: T, previous: T, onCleanup: (cleanup: () => void) => void) => unknown,
    options: { array?: boolean; immediate?: boolean; post?: boolean } = {},
  ) {
    this.#owner = owner;
    this.#source = source;
    this.#callback = callback;
    this.#options = options;
    registerDestructor(owner, () => this.#cleanup?.());
  }

  readonly flush = (): undefined => {
    const value = this.#source();
    const started = this.#started;
    if (started && this.#same(value, this.#value as T)) return undefined;
    const previous = (started ? this.#value : this.#options.array ? [] : undefined) as T;
    this.#started = true;
    this.#value = value;
    if (!started && !this.#options.immediate) return undefined;
    const run = () => {
      const cleanup = this.#cleanup;
      this.#cleanup = undefined;
      cleanup?.();
      void this.#callback(value, previous, (each) => {
        this.#cleanup = each;
      });
    };
    // The render that calls `flush` has read what the callback may write, so the callback
    // runs right after it, or once the render settles for a `post` watcher.
    const later = () => {
      if (!isDestroying(this.#owner)) run();
    };
    if (this.#options.post) void renderSettled().then(later);
    else {
      callbacks.pending += 1;
      queueMicrotask(() => {
        callbacks.pending -= 1;
        later();
      });
    }
    return undefined;
  };

  #same(value: T, previous: T): boolean {
    if (!this.#options.array) return Object.is(value, previous);
    const values = value as unknown[];
    const previousValues = previous as unknown[];
    return values.every((each, index) => Object.is(each, previousValues[index]));
  }
}

/** How many watchers' callbacks are to run once the current render is done. */
const callbacks = { pending: 0 };

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
