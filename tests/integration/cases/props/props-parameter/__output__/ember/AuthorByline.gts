import Component from "@glimmer/component";

export interface AuthorBylineProps {
  author: string;
  published: string;
  minutes: number;
  affiliation?: string;
}

export interface AuthorBylineSignature {
  Args: AuthorBylineProps;
  Element: HTMLElementTagNameMap["p"];
}

export default class AuthorByline extends Component<AuthorBylineSignature> {
  get value1() {
    return this.args.affiliation ?? "independent";
  }

  <template><p
      class="byline"
      ...attributes
    >By {{@author}}, {{this.value1}}<br><time datetime={{@published}}>{{@published}}</time> · {{@minutes}} min read</p></template>
}
