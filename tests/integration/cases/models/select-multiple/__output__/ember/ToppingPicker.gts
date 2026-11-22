import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface ToppingPickerSignature {
  Element: HTMLElementTagNameMap["section"];
}

export default class ToppingPicker extends Component<ToppingPickerSignature> {
  @tracked toppings: string[] = ["cheese"];

  get value1() {
    return this.toppings.includes("cheese");
  }

  get value2() {
    return this.toppings.includes("olives");
  }

  get value3() {
    return this.toppings.includes("basil");
  }

  listener1 = (event: Event) => {
    this.toppings = Array.from(
      (event.currentTarget as HTMLSelectElement).selectedOptions,
      (option) => option.value,
    );
  };

  get value4() {
    return this.toppings.join(", ") || "nothing";
  }

  listener2 = () => (this.toppings = ["basil", "olives"]);

  <template><section
      aria-label="Pizza"
      ...attributes
    ><label>Toppings <select
      multiple
      {{on "change" this.listener1}}
    ><option value="cheese" selected={{this.value1}}>Cheese</option><option
      value="olives" selected={{this.value2}}
    >Olives</option><option value="basil" selected={{this.value3}}>Basil</option></select></label><output>On top: {{this.value4}}</output><button
      type="button"
      {{on "click" this.listener2}}
    >Green</button></section></template>
}
