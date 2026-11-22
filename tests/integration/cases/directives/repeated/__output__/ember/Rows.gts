import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface RowsSignature {
  Blocks: { row: [] };
  Element: HTMLElementTagNameMap["div"];
}

export default class Rows extends Component<RowsSignature> {
  @tracked items = [1, 2];

  listener1 = () => (this.items = [...this.items, this.items.length + 1]);

  listener2 = () => (this.items = this.items.slice(0, -1));

  <template><div
      class="rows"
      ...attributes
    ><ul>{{#each this.items key="@identity" as |item|}}<li>{{yield to="row"}}</li>{{/each}}</ul><button
      type="button"
      {{on "click" this.listener1}}
    >Add row</button><button type="button" {{on "click" this.listener2}}>Remove row</button></div></template>
}
