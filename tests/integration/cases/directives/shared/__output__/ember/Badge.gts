import type { TOC } from "@ember/component/template-only";
import { vMark } from "./vMark.ts";

export interface BadgeProps {
  label: string;
}

export interface BadgeSignature {
  Args: BadgeProps;
  Element: HTMLElementTagNameMap["span"];
}

const Badge: TOC<BadgeSignature> = <template><span class="badge" {{vMark "badge"}} ...attributes>{{@label}}</span></template>;

export default Badge;
