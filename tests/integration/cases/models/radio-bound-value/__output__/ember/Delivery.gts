import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface DeliveryProps {
  speeds: string[];
  extras: string[];
}

export interface DeliverySignature {
  Args: DeliveryProps;
  Element: HTMLElementTagNameMap["section"];
}

export default class Delivery extends Component<DeliverySignature> {
  @tracked speed = "express";

  @tracked chosen: string[] = ["insurance"];

  value1 = (value: NonNullable<this["args"]["speeds"]>[number]) => this.speed === value;

  listener1 = (value: NonNullable<this["args"]["speeds"]>[number]) => () => {
    this.speed = value;
  };

  value2 = (extra: NonNullable<this["args"]["extras"]>[number]) => this.chosen.includes(extra);

  listener2 = (extra: NonNullable<this["args"]["extras"]>[number]) => (event: Event) => {
    this.chosen = toggle(this.chosen, extra, (event.currentTarget as HTMLInputElement).checked);
  };

  get value3() {
    return this.chosen.join(", ") || "none";
  }

  <template><section
      aria-label="Delivery"
      ...attributes
    ><fieldset><legend>Speed</legend>{{#each @speeds key="@identity" as |value|}}<label><input
      type="radio"
      name="speed"
      value={{value}}
      checked={{this.value1 value}}
      {{on "change" (this.listener1 value)}}
    > {{value}}</label>{{/each}}</fieldset><fieldset><legend>Extras</legend>{{#each @extras key="@identity" as |extra|}}<label><input
      type="checkbox"
      value={{extra}}
      checked={{this.value2 extra}}
      {{on "change" (this.listener2 extra)}}
    > {{extra}}</label>{{/each}}</fieldset><output>Speed: {{this.speed}}, extras: {{this.value3}}</output></section></template>
}

/** The values with `value` added when `checked`, and removed otherwise. */
function toggle<T>(values: readonly T[], value: T, checked: boolean): T[] {
  return checked ? values.concat([value]) : values.filter((each) => each !== value);
}
