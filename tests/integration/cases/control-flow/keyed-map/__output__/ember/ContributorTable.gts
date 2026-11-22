import Component from "@glimmer/component";

export interface Contributor {
  login: string;
  name: string;
  commits: number;
}

export interface ContributorTableProps {
  caption: string;
  contributors: Contributor[];
}

export interface ContributorTableSignature {
  Args: ContributorTableProps;
  Element: HTMLElementTagNameMap["table"];
}

export default class ContributorTable extends Component<ContributorTableSignature> {
  value1 = (contributor: NonNullable<this["args"]["contributors"]>[number]) =>
    `https://example.com/people/${contributor.login}`;

  <template><table
      class="contributors"
      ...attributes
    ><caption>{{@caption}}</caption><thead><tr><th scope="col">Name</th><th scope="col">Commits</th></tr></thead><tbody>{{#each @contributors key="login" as |contributor|}}<tr><td><a
      href={{this.value1 contributor}}
    >{{contributor.name}}</a></td><td>{{contributor.commits}}</td></tr>{{/each}}</tbody></table></template>
}
