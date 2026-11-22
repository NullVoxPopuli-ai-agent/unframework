import type { TOC } from "@ember/component/template-only";
import Badge from "./Badge.gts";
import Panel from "./Panel.gts";

export interface PageSignature {
  Element: HTMLElementTagNameMap["main"];
}

const Page: TOC<PageSignature> = <template><main ...attributes><Panel @id="ada"><Badge /></Panel></main></template>;

export default Page;
