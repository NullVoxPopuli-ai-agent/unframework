import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { vRecord } from "./vRecord.ts";

export interface MeterSignature {
  Element: HTMLElementTagNameMap["section"];
}

export default class Meter extends Component<MeterSignature> {
  @tracked level = 1;

  @tracked renders = 0;

  listener1 = () => this.level++;

  listener2 = () => this.renders++;

  <template><section
      class="meter"
      aria-label="Meter"
      ...attributes
    ><output class="level" {{vRecord this.level}}>Level {{this.level}}</output><p>Rendered again {{this.renders}} times</p><button
      type="button"
      {{on "click" this.listener1}}
    >Raise</button><button type="button" {{on "click" this.listener2}}>Render again</button></section></template>
}
