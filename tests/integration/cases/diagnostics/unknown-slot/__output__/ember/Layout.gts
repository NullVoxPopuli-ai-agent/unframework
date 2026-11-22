import type { TOC } from "@ember/component/template-only";

export interface LayoutSignature {
  Blocks: { title: []; default: [] };
  Element: HTMLElementTagNameMap["main"];
}

export const Layout: TOC<LayoutSignature> = <template><main ...attributes><h1>{{yield to="title"}}</h1>{{yield}}</main></template>;
