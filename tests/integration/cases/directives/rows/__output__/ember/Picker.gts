import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface PickerSignature {
  Blocks: { option: [props: { option: { id: string; label: string } }] };
  Element: HTMLElementTagNameMap["div"];
}

export default class Picker extends Component<PickerSignature> {
  @tracked options = [
    { id: "x", label: "Xray" },
    { id: "y", label: "Yankee" },
  ];

  value1 = (option: NonNullable<this["options"]>[number]) => ({ option });

  listener1 = () => (this.options = [...this.options].reverse());

  listener2 = () => (this.options = this.options.filter((option) => option.id !== "y"));

  <template><div
      class="picker"
      ...attributes
    ><ul
      aria-label="Options"
    >{{#each this.options key="id" as |option|}}<li>{{yield (this.value1 option) to="option"}}</li>{{/each}}</ul><button
      type="button"
      {{on "click" this.listener1}}
    >Reverse options</button><button
      type="button"
      {{on "click" this.listener2}}
    >Remove option</button></div></template>
}
