import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface StepperProps {
  start?: number;
}

export interface StepperEvents {
  onChange?: (value: number) => void;
}

export interface StepperSignature {
  Args: StepperProps & StepperEvents;
  Element: HTMLElementTagNameMap["div"];
}

export default class Stepper extends Component<StepperSignature> {
  get start() {
    return this.args.start === undefined ? 0 : this.args.start;
  }

  add = () => {
    this.count += 1;
    this.args.onChange?.(this.count);
  };

  @tracked count = this.start;

  <template><div
      class="stepper"
      ...attributes
    ><output>{{this.count}}</output><button type="button" {{on "click" this.add}}>Add one</button></div></template>
}
