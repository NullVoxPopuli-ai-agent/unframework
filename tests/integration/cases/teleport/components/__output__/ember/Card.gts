import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface CardSignature {
  Blocks: { default: [] };
  Element: HTMLElementTagNameMap["div"];
}

export default class Card extends Component<CardSignature> {
  @tracked open = false;

  listener1 = () => (this.open = !this.open);

  <template><div
      class="card"
      ...attributes
    ><button type="button" {{on "click" this.listener1}}>Toggle card</button>{{#if this.open}}<div
      class="body"
    >{{yield}}</div>{{/if}}</div></template>
}
