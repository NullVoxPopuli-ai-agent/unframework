import type { TOC } from "@ember/component/template-only";

export interface CommentQuoteProps {
  author: string;
  comment: string;
}

export interface CommentQuoteSignature {
  Args: CommentQuoteProps;
  Element: HTMLElementTagNameMap["figure"];
}

const CommentQuote: TOC<CommentQuoteSignature> = <template><figure
    class="comment-quote"
    ...attributes
  ><blockquote style="margin: 0; padding: 0"><p dir="auto">{{@comment}}</p></blockquote><figcaption>{{@author}}</figcaption></figure></template>;

export default CommentQuote;
