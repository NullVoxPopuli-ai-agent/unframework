import type { TOC } from "@ember/component/template-only";
import Toast from "./Toast.gts";
import "./Page.uf.tsx.css";

export interface PageProps {
  message: string;
}

export interface PageSignature {
  Args: PageProps;
  Element: HTMLElementTagNameMap["section"];
}

const Page: TOC<PageSignature> = <template><section
    class="page"
    aria-label="Page"
    data-uf-5a3bed67=""
    ...attributes
  ><p data-uf-5a3bed67="">Saving…</p><Toast @message={{@message}} data-uf-5a3bed67="" /></section></template>;

export default Page;
