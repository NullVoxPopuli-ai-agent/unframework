import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import Panel from "./Panel.gts";

export interface BoardSignature {
  Element: HTMLElementTagNameMap["div"];
}

export default class Board extends Component<BoardSignature> {
  record = (entry: string) => {
    this.entries = [...this.entries, entry];
  };

  @tracked showA = true;

  @tracked showB = true;

  @tracked entries: string[] = [];

  listener1 = () => (this.showA = false);

  listener2 = () => (this.showB = false);

  get value1() {
    return this.entries.join(", ");
  }

  <template><div
      class="board"
      ...attributes
    >{{#if this.showA}}<Panel @name="a" @onClosed={{this.record}} />{{/if}}{{#if this.showB}}<Panel
      @name="b"
      @onClosed={{this.record}}
    />{{/if}}<button type="button" {{on "click" this.listener1}}>Hide a</button><button
      type="button"
      {{on "click" this.listener2}}
    >Hide b</button><output>{{this.value1}}</output></div></template>
}
