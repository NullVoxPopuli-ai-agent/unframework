import Component from "@glimmer/component";

export interface ArticleTeaserProps {
  title: string;
  summary: string;
  author: string;
  minutes?: number;
  featured?: boolean;
  category?: string;
  pinned?: boolean;
  layout?: "row" | "column";
}

export interface ArticleTeaserSignature {
  Args: ArticleTeaserProps;
  Element: HTMLElementTagNameMap["article"];
}

export default class ArticleTeaser extends Component<ArticleTeaserSignature> {
  get minutes() {
    return this.args.minutes === undefined ? 5 : this.args.minutes;
  }

  get pinned() {
    return this.args.pinned === undefined ? false : this.args.pinned;
  }

  get layout() {
    return this.args.layout === undefined ? "row" : this.args.layout;
  }

  <template><article
      class="article-teaser"
      aria-label={{@title}}
      ...attributes
    ><h2>{{@title}}</h2><p>{{@summary}}</p><p
      class="article-teaser-meta"
    >{{this.minutes}} min read</p></article></template>
}
