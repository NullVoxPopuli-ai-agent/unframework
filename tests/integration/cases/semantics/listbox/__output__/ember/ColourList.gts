import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface ColourListSignature {
  Element: HTMLElementTagNameMap["section"];
}

export default class ColourList extends Component<ColourListSignature> {
  @tracked colour = "none";

  listener1 = (event: HTMLElementEventMap["change"]) =>
    (this.colour = (event.currentTarget as HTMLSelectElement).value);

  <template><section
      aria-label="Colours"
      ...attributes
    ><select
      size="3"
      aria-label="Colour"
      {{on "change" this.listener1}}
    ><option value="red">Red</option><option value="green">Green</option><option
      value="blue"
    >Blue</option></select><output>Picked: {{this.colour}}</output></section></template>
}
