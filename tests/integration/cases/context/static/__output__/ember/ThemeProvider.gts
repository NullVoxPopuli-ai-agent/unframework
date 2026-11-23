import Component from "@glimmer/component";
import { cached } from "@glimmer/tracking";
import Badge from "./Badge.gts";

export interface Theme {
  accent: string;
  label: string;
}

export const ThemeKey = Symbol("uf.theme");

export interface ThemeProviderSignature {
  Element: HTMLElementTagNameMap["section"];
}

export default class ThemeProvider extends Component<ThemeProviderSignature> {
  @cached
  get providerMarker(): Text {
    return provider([[ThemeKey, { accent: "teal", label: "Teal" }]]);
  }

  <template><section
      aria-label="Themed"
      ...attributes
    >{{this.providerMarker}}<Badge @text="New" /></section></template>
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
