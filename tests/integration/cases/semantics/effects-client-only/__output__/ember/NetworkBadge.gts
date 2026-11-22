import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { isDestroying, registerDestructor } from "@ember/destroyable";
import { renderSettled } from "@ember/renderer";

export interface NetworkBadgeSignature {
  Element: HTMLElementTagNameMap["p"];
}

export default class NetworkBadge extends Component<NetworkBadgeSignature> {
  @tracked online: boolean | undefined = undefined;

  @tracked label = "Checking the connection";

  readonly watcher1 = new Watcher(
    this,
    () => this.online,
    (value) => {
      this.label = value ? "Online" : "Offline";
    },
  );

  #mounted = false;

  /** Called at the template's end: the hooks run once the component has rendered. */
  onMounted = (): undefined => {
    if (!this.#mounted) {
      this.#mounted = true;
      afterRender(this, () => {
        this.online = navigator.onLine;
      });
    }
    return undefined;
  };

  get value1() {
    return this.online === undefined ? "no" : "yes";
  }

  <template>{{(this.watcher1.flush)}}<p
      class="network-badge"
      role="status"
      data-checked={{this.value1}}
      ...attributes
    >{{this.label}}</p>{{(this.onMounted)}}</template>
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

/** Runs `run` once the render settles, unless its component is gone by then. */
function afterRender(owner: object, run: () => unknown): void {
  void renderSettled().then(() => {
    if (!isDestroying(owner)) void run();
  });
}

/** How many watchers' callbacks are to run once the current render is done. */
const callbacks = { pending: 0 };
