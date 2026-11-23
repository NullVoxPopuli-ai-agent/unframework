import Component from "@glimmer/component";
import { cached } from "@glimmer/tracking";
import { LocaleKey } from "./LocaleProvider.gts";

export interface GreetingSignature {
  Args: { name: string };
  Element: HTMLElementTagNameMap["p"];
}

export default class Greeting extends Component<GreetingSignature> {
  readonly injectionMarker = document.createTextNode("");

  @cached
  get locale(): string {
    return inject(this.injectionMarker, LocaleKey, "en");
  }

  get value1() {
    return this.locale === "pt" ? "Olá" : "Hello";
  }

  <template>{{this.injectionMarker}}<p ...attributes>{{this.value1}}, {{@name}} ({{this.locale}})</p></template>
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
