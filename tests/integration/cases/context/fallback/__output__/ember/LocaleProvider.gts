import Component from "@glimmer/component";
import { cached } from "@glimmer/tracking";

export const LocaleKey = Symbol("uf.locale");

export interface LocaleProviderSignature {
  Args: { locale: string };
  Blocks: { default: [] };
  Element: HTMLElementTagNameMap["div"];
}

export default class LocaleProvider extends Component<LocaleProviderSignature> {
  @cached
  get providerMarker(): Text {
    return provider([[LocaleKey, this.args.locale]]);
  }

  <template><div lang={{@locale}} ...attributes>{{this.providerMarker}}{{yield}}</div></template>
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
