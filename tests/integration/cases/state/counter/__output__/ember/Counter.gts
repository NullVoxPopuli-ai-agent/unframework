import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface CounterProps {
  initial?: number;
  step?: number;
}

export interface CounterEvents {
  onChange?: (value: number) => void;
}

export interface CounterSignature {
  Args: CounterProps & CounterEvents;
  Element: HTMLElementTagNameMap["div"];
}

export default class Counter extends Component<CounterSignature> {
  get initial() {
    return this.args.initial === undefined ? 0 : this.args.initial;
  }

  get step() {
    return this.args.step === undefined ? 1 : this.args.step;
  }

  increment = () => {
    this.count += this.step;
    this.args.onChange?.(this.count);
  };

  @tracked count = this.initial;

  get doubled() {
    return this.count * 2;
  }

  get value1() {
    return this.doubled > 10;
  }

  <template><div
      class="counter"
      ...attributes
    ><output>{{this.count}}</output>{{#if this.value1}}<span>Big</span>{{/if}}<button
      type="button"
      {{on "click" this.increment}}
    >+{{this.step}}</button></div></template>
}
