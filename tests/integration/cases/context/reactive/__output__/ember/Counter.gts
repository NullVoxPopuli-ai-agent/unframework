import Component from "@glimmer/component";
import { cached, tracked } from "@glimmer/tracking";
import Display from "./Display.gts";

export const CountKey = Symbol("uf.count");

export interface CounterSignature {
  Element: HTMLElementTagNameMap["section"];
}

export default class Counter extends Component<CounterSignature> {
  @tracked count = 1;

  @cached
  get providerMarker(): Text {
    return provider([[CountKey, refOf(() => this.count)]]);
  }

  listener1 = () => (this.count += 1);

  <template><section
      aria-label="Counter"
      ...attributes
    >{{this.providerMarker}}<Display /><button
      type="button"
      {{on "click" this.listener1}}
    >Add one</button></section></template>
}

/**
 * Vue's `provide`: a text node, first in the component's root, that holds each provided value
 * under its key. The root's descendants find it, and no sibling of the root does (`inject`).
 */
function provider(entries: readonly (readonly [symbol, unknown])[]): Text {
  const marker = document.createTextNode("");
  for (const [key, value] of entries) Reflect.set(marker, key, value);
  return marker;
}

/** A provided state as its consumers read a ref: a `value` getter over the tracked field. */
function refOf<T>(read: () => T): { readonly value: T } {
  return {
    get value() {
      return read();
    },
  };
}
