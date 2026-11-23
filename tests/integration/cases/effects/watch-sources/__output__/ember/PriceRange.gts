import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { isDestroying, registerDestructor } from "@ember/destroyable";
import { renderSettled } from "@ember/renderer";

export interface PriceRangeProps {
  currency: string;
}

export interface PriceRangeEvents {
  onSpanUpdate?: (span: number) => void;
  onRangeUpdate?: (low: number, high: number) => void;
  onCurrencyUpdate?: (currency: string) => void;
}

export interface PriceRangeSignature {
  Args: PriceRangeProps & PriceRangeEvents;
  Element: HTMLElementTagNameMap["section"];
}

export default class PriceRange extends Component<PriceRangeSignature> {
  @tracked low = 10;

  @tracked high = 50;

  readonly watcher1 = new Watcher(
    this,
    () => this.high - this.low,
    (span) => {
      this.args.onSpanUpdate?.(span);
    },
  );

  readonly watcher2 = new Watcher(
    this,
    () => sources(this.low, this.high),
    ([minimum, maximum]) => {
      this.args.onRangeUpdate?.(minimum, maximum);
    },
    { array: true },
  );

  readonly watcher3 = new Watcher(
    this,
    () => this.args.currency,
    (value) => {
      this.args.onCurrencyUpdate?.(value);
    },
  );

  listener1 = () => {
    this.low += 10;
    this.high += 10;
  };

  listener2 = () => (this.high += 10);

  <template>{{(this.watcher1.flush)}}{{(this.watcher2.flush)}}{{(this.watcher3.flush)}}<section
      class="price-range"
      aria-label="Price range"
      ...attributes
    ><p role="status">{{this.low}} to {{this.high}} {{@currency}}</p><button
      type="button"
      {{on "click" this.listener1}}
    >Shift up</button><button type="button" {{on "click" this.listener2}}>Widen</button></section></template>
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
    // On the server a watcher runs at most its immediate first run, as Vue's does.
    if (import.meta.env.SSR && started) return undefined;
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

/** An array of watch sources, typed as a tuple. */
function sources<T extends unknown[]>(...values: T): T {
  return values;
}
