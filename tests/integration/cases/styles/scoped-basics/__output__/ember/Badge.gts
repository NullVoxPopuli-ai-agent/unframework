import type { TOC } from "@ember/component/template-only";
import "./Badge.uf.tsx.css";

export interface BadgeSignature {
  Args: { label: string; count: number };
  Element: HTMLElementTagNameMap["span"];
}

const Badge: TOC<BadgeSignature> = <template><span
    class="badge"
    data-uf-d9cef2e7=""
    ...attributes
  ><span class="label" data-uf-d9cef2e7="">{{@label}}</span><span
    class="count"
    data-uf-d9cef2e7=""
  >{{@count}}</span></span></template>;

export default Badge;
