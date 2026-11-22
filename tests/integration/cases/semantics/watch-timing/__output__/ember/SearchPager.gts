import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { isDestroying, registerDestructor } from "@ember/destroyable";
import { renderSettled } from "@ember/renderer";

export interface SearchPagerEvents {
  onQueryRun?: (value: string, previous: string) => void;
  onPageRun?: (value: number, previous: number) => void;
  onCleanedUp?: (watcher: string) => void;
}

export interface SearchPagerSignature {
  Args: SearchPagerEvents;
  Element: HTMLElementTagNameMap["section"];
}

export default class SearchPager extends Component<SearchPagerSignature> {
  search = (term: string) => {
    this.query = term;
    this.query = this.query.toLowerCase();
    this.page = 1;
  };

  nextPage = () => {
    this.page += 1;
  };

  skipTwoPages = () => {
    this.page += 1;
    this.page += 1;
  };

  @tracked query = "";

  @tracked page = 1;

  readonly watcher1 = new Watcher(
    this,
    () => this.query,
    (value, previous, onCleanup) => {
      this.args.onQueryRun?.(value, previous);
      onCleanup(() => {
        this.args.onCleanedUp?.("query");
      });
    },
  );

  readonly watcher2 = new Watcher(
    this,
    () => this.page,
    (value, previous) => {
      this.args.onPageRun?.(value, previous);
    },
  );

  get value1() {
    return this.query === "" ? "All results" : `Results for ${this.query}`;
  }

  listener1 = () => this.search("Boots");

  listener2 = () => this.search("Sandals");

  <template>{{(this.watcher1.flush)}}{{(this.watcher2.flush)}}<section
      class="search-pager"
      aria-label="Search"
      ...attributes
    ><p role="status">{{this.value1}}, page {{this.page}}</p><button
      type="button"
      {{on "click" this.listener1}}
    >Search boots</button><button
      type="button"
      {{on "click" this.listener2}}
    >Search sandals</button><button type="button" {{on "click" this.nextPage}}>Next page</button><button
      type="button"
      {{on "click" this.skipTwoPages}}
    >Skip two pages</button></section></template>
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
