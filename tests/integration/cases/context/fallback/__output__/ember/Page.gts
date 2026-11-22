import type { TOC } from "@ember/component/template-only";
import Greeting from "./Greeting.gts";
import LocaleProvider from "./LocaleProvider.gts";

export interface PageSignature {
  Element: HTMLElementTagNameMap["main"];
}

const Page: TOC<PageSignature> = <template><main
    ...attributes
  ><Greeting @name="Ada" /><LocaleProvider @locale="pt"><Greeting @name="Inês" /></LocaleProvider></main></template>;

export default Page;
