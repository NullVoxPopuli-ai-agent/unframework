import type { TOC } from "@ember/component/template-only";
import { htmlSafe } from "@ember/template";

export interface ArticleProps {
  title: string;
  body: string;
}

export interface ArticleSignature {
  Args: ArticleProps;
  Element: HTMLElementTagNameMap["article"];
}

const Article: TOC<ArticleSignature> = <template><article
    class="article"
    ...attributes
  ><h2>{{@title}}</h2><div class="body">{{htmlSafe @body}}</div><footer>{{htmlSafe "<small>Filed under <em>News</em></small>"}}</footer></article></template>;

export default Article;
