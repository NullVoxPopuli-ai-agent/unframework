import Component from "@glimmer/component";
import { cached, tracked } from "@glimmer/tracking";
import { CountKey } from "./Counter.gts";

export interface DisplaySignature {
  Element: HTMLElementTagNameMap["output"];
}

export default class Display extends Component<DisplaySignature> {
  readonly injectionMarker = document.createTextNode("");

  @tracked none = 0;

  @cached
  get count(): { readonly value: number } {
    return inject(
      this.injectionMarker,
      CountKey,
      refOf(() => this.none),
    );
  }

  <template>{{this.injectionMarker}}<output ...attributes>Count: {{this.count.value}}</output></template>
}

/**
 * Vue's `inject`: the value of the nearest provider above `marker`, or the fallback. Ember
 * has no context API yet (RFC 1200), so this walks the DOM, as ember-primitives' dom-context
 * does: each ancestor and the nodes before it, where a provider's marker sits.
 */
function inject<T>(marker: Node, key: symbol, fallback: T): T {
  for (let parent: Node | null = marker; parent; parent = parent.parentNode) {
    for (let node = parent.previousSibling; node; node = node.previousSibling) {
      if (Reflect.has(node, key)) return Reflect.get(node, key) as T;
    }
  }
  return fallback;
}

/** A provided state as its consumers read a ref: a `value` getter over the tracked field. */
function refOf<T>(read: () => T): { readonly value: T } {
  return {
    get value() {
      return read();
    },
  };
}
