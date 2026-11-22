import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { formatDistance } from "./format";
import type { Unit } from "./units";

export interface DistanceSignature {
  Args: { value: number };
  Element: HTMLElementTagNameMap["section"];
}

export default class Distance extends Component<DistanceSignature> {
  @tracked unit: Unit = "km";

  get value1() {
    return formatDistance(this.args.value, this.unit);
  }

  listener1 = () => (this.unit = this.unit === "km" ? "mi" : "km");

  <template><section
      class="distance"
      aria-label="Distance"
      ...attributes
    ><p role="status">{{this.value1}}</p><button
      type="button"
      {{on "click" this.listener1}}
    >Switch units</button></section></template>
}
