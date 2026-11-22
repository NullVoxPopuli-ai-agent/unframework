import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface ChoiceSignature {
  Blocks: { body: [] };
  Element: HTMLElementTagNameMap["div"];
}

export default class Choice extends Component<ChoiceSignature> {
  @tracked first = true;

  listener1 = () => (this.first = !this.first);

  <template><div
      class="choice"
      ...attributes
    >{{#if this.first}}<b>{{yield to="body"}}</b>{{else}}<i>{{yield to="body"}}</i>{{/if}}<button
      type="button"
      {{on "click" this.listener1}}
    >Switch</button></div></template>
}
