import Component from "@glimmer/component";
import { cached } from "@glimmer/tracking";

export const ToneKey = Symbol("uf.tone");

export interface BadgeSignature {
  Element: HTMLElementTagNameMap["span"];
}

export default class Badge extends Component<BadgeSignature> {
  readonly injectionMarker = document.createTextNode("");

  @cached
  get tone(): string {
    return inject(this.injectionMarker, ToneKey, "plain");
  }

  <template>{{this.injectionMarker}}<span class="badge" ...attributes>Tone: {{this.tone}}</span></template>
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
