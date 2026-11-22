import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

const STEPS = [1, 5, 10] as const;
const LIMITS = Object.freeze({ min: 0, max: 20 });
const caption = (value: number): string => `${value} of ${LIMITS.max}`;
const START = LIMITS.min + 2;

export interface StepperSignature {
  Element: HTMLElementTagNameMap["section"];
}

export default class Stepper extends Component<StepperSignature> {
  add = (step: number) => {
    this.value = Math.min(LIMITS.max, this.value + step);
  };

  @tracked value = START;

  get value1() {
    return caption(this.value);
  }

  get value2() {
    return STEPS;
  }

  listener1 = (step: NonNullable<this["value2"]>[number]) => () => this.add(step);

  <template><section
      class="stepper"
      aria-label="Stepper"
      ...attributes
    ><p role="status">{{this.value1}}</p><ul>{{#each this.value2 key="@identity" as |step|}}<li><button
      type="button"
      {{on "click" (this.listener1 step)}}
    >Add {{step}}</button></li>{{/each}}</ul></section></template>
}
