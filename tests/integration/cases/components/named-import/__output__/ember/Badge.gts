import type { TOC } from "@ember/component/template-only";

export interface BadgeSignature {
  Args: { text: string };
  Element: HTMLElementTagNameMap["span"];
}

export const Badge: TOC<BadgeSignature> = <template><span class="badge" ...attributes>{{@text}}</span></template>;
