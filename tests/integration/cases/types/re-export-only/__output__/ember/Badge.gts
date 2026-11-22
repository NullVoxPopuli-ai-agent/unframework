import type { TOC } from "@ember/component/template-only";

export type { Tone } from "./tone";

export interface BadgeSignature {
  Args: { label: string };
  Element: HTMLElementTagNameMap["span"];
}

const Badge: TOC<BadgeSignature> = <template><span class="badge" ...attributes>{{@label}}</span></template>;

export default Badge;
