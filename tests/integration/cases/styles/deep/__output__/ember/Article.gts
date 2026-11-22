import type { TOC } from "@ember/component/template-only";
import Note from "./Note.gts";
import "./Article.uf.tsx.css";

export interface ArticleSignature {
  Args: { title: string; note: string };
  Element: HTMLElementTagNameMap["article"];
}

const Article: TOC<ArticleSignature> = <template><article
    class="article"
    data-uf-15946226=""
    ...attributes
  ><h2 class="title" data-uf-15946226="">{{@title}}</h2><Note
    @text={{@note}}
    data-uf-15946226=""
  /></article></template>;

export default Article;
