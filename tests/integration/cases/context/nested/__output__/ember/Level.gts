import Component from "@glimmer/component";
import { cached } from "@glimmer/tracking";

export const DepthKey = Symbol("uf.depth");

export interface LevelSignature {
  Args: { title: string };
  Blocks: { default: [] };
  Element: HTMLElementTagNameMap["section"];
}

export default class Level extends Component<LevelSignature> {
  readonly injectionMarker = document.createTextNode("");

  @cached
  get depth(): number {
    return inject(this.injectionMarker, DepthKey, 0);
  }

  @cached
  get providerMarker(): Text {
    return provider([[DepthKey, this.depth + 1]]);
  }

  <template>{{this.injectionMarker}}<section
      aria-label={{@title}}
      ...attributes
    >{{this.providerMarker}}<h2>{{@title}} at depth {{this.depth}}</h2>{{yield}}</section></template>
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

/**
 * Vue's `provide`: a text node, first in the component's root, that holds each provided value
 * under its key. The root's descendants find it, and no sibling of the root does (`inject`).
 */
function provider(entries: readonly (readonly [symbol, unknown])[]): Text {
  const marker = document.createTextNode("");
  for (const [key, value] of entries) Reflect.set(marker, key, value);
  return marker;
}
