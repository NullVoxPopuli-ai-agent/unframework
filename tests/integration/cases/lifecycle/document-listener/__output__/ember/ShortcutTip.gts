import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { isDestroying, registerDestructor } from "@ember/destroyable";
import { renderSettled } from "@ember/renderer";

export interface ShortcutTipEvents {
  onDismissed?: () => void;
  onShortcut?: (key: string, count: number) => void;
}

export interface ShortcutTipSignature {
  Args: ShortcutTipEvents;
  Element: HTMLElementTagNameMap["section"];
}

export default class ShortcutTip extends Component<ShortcutTipSignature> {
  onEscape = (event: KeyboardEvent) => {
    if (event.key === "Escape") {
      this.open = false;
      this.args.onDismissed?.();
    }
  };

  onShortcut = (event: KeyboardEvent) => {
    if (event.key === "k") {
      this.count += 1;
      this.args.onShortcut?.(event.key, this.count);
    }
  };

  toggle = () => {
    this.enabled = !this.enabled;
  };

  @tracked open = true;

  @tracked enabled = false;

  @tracked count = 0;

  readonly watcher1 = new Watcher(
    this,
    () => this.enabled,
    (on) => {
      if (on) {
        document.addEventListener("keydown", this.onShortcut);
      } else {
        document.removeEventListener("keydown", this.onShortcut);
      }
    },
    { post: true },
  );

  #mounted = false;

  /** Called at the template's end: the hooks run once the component has rendered. */
  onMounted = (): undefined => {
    if (!this.#mounted) {
      this.#mounted = true;
      afterRender(this, () => {
        document.addEventListener("keydown", this.onEscape);
      });
      afterRender(this, () =>
        registerDestructor(this, () => {
          document.removeEventListener("keydown", this.onEscape);
          document.removeEventListener("keydown", this.onShortcut);
        }),
      );
    }
    return undefined;
  };

  get value1() {
    return this.open ? "Press Escape to hide this tip." : "Tip hidden.";
  }

  <template>{{(this.watcher1.flush)}}<section
      class="shortcut-tip"
      aria-label="Shortcuts"
      ...attributes
    ><p>{{this.value1}}</p><button
      type="button"
      aria-pressed={{enumeratedValue this.enabled}}
      {{on "click" this.toggle}}
    >Shortcut K</button><p role="status">Used: {{this.count}}</p></section>{{(this.onMounted)}}</template>
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

/** An enumerated attribute's value: a boolean as its name, any other value as it is. */
function enumeratedValue<T>(value: T): Exclude<T, boolean> | "true" | "false" {
  return typeof value === "boolean"
    ? (String(value) as "true" | "false")
    : (value as Exclude<T, boolean>);
}
