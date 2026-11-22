import type { TOC } from "@ember/component/template-only";

export interface ArticleSkeletonProps {
  title: string;
  summary?: string;
  minutes?: number;
}

export interface ArticleSkeletonSignature {
  Args: ArticleSkeletonProps;
  Element: HTMLElementTagNameMap["article"];
}

const ArticleSkeleton: TOC<ArticleSkeletonSignature> = <template><article
    class="article-skeleton"
    aria-busy="true"
    aria-label="Loading article"
    ...attributes
  ><p>Loading the article</p></article></template>;

export default ArticleSkeleton;
