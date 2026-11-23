import Component from "@glimmer/component";
import { cached } from "@glimmer/tracking";
import { type Theme, ThemeKey } from "./ThemeProvider.gts";

export interface BadgeSignature {
  Args: { text: string };
  Element: HTMLElementTagNameMap["span"];
}

export default class Badge extends Component<BadgeSignature> {
  readonly injectionMarker = document.createTextNode("");

  @cached
  get theme(): Theme | undefined {
    return inject(this.injectionMarker, ThemeKey, undefined);
  }

  get value1() {
    return this.theme?.label ?? "no theme";
  }

  get value2() {
    return classNames("badge", this.theme?.accent);
  }

  <template>{{this.injectionMarker}}<span class={{this.value2}} ...attributes>{{@text}} in {{this.value1}}</span></template>
}

/** A class as clsx builds it: strings, arrays and toggle objects, empty tokens left out. */
function classNames(...values: unknown[]): string | undefined {
  const tokens: string[] = [];
  const add = (value: unknown): void => {
    if (!value) return;
    if (typeof value === "string" || typeof value === "number") tokens.push(String(value));
    else if (Array.isArray(value)) for (const each of value) add(each);
    else if (typeof value === "object") {
      for (const [name, on] of Object.entries(value)) if (on) tokens.push(name);
    }
  };
  for (const value of values) add(value);
  return tokens.length ? tokens.join(" ") : undefined;
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
