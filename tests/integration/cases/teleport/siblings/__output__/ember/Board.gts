import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import Panel from "./Panel.gts";

export interface BoardSignature {
  Element: HTMLElementTagNameMap["main"];
}

export default class Board extends Component<BoardSignature> {
  @tracked shown = true;

  listener1 = () => (this.shown = false);

  <template><main
      class="board"
      ...attributes
    ><button type="button" {{on "click" this.listener1}}>Remove panel</button>{{#if this.shown}}<Panel />{{/if}}</main></template>
}
