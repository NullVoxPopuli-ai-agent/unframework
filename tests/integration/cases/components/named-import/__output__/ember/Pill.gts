import type { TOC } from "@ember/component/template-only";

export interface PillSignature {
  Args: { text: string };
  Element: HTMLElementTagNameMap["span"];
}

export const Pill: TOC<PillSignature> = <template><span class="pill" ...attributes>{{@text}}</span></template>;
