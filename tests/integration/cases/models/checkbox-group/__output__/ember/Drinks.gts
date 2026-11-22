import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface DrinksSignature {
  Element: HTMLElementTagNameMap["fieldset"];
}

export default class Drinks extends Component<DrinksSignature> {
  @tracked drinks: string[] = ["tea"];

  get value1() {
    return this.drinks.includes("tea");
  }

  listener1 = (event: Event) => {
    this.drinks = toggle(this.drinks, "tea", (event.currentTarget as HTMLInputElement).checked);
  };

  get value2() {
    return this.drinks.includes("coffee");
  }

  listener2 = (event: Event) => {
    this.drinks = toggle(this.drinks, "coffee", (event.currentTarget as HTMLInputElement).checked);
  };

  get value3() {
    return this.drinks.includes("juice");
  }

  listener3 = (event: Event) => {
    this.drinks = toggle(this.drinks, "juice", (event.currentTarget as HTMLInputElement).checked);
  };

  get value4() {
    return this.drinks.join(", ") || "nothing";
  }

  listener4 = () => (this.drinks = ["juice"]);

  <template><fieldset
      ...attributes
    ><legend>Drinks</legend><label><input
      type="checkbox"
      value="tea"
      checked={{this.value1}}
      {{on "change" this.listener1}}
    > Tea</label><label><input
      type="checkbox"
      value="coffee"
      checked={{this.value2}}
      {{on "change" this.listener2}}
    > Coffee</label><label><input
      type="checkbox"
      value="juice"
      checked={{this.value3}}
      {{on "change" this.listener3}}
    > Juice</label><output>Ordered: {{this.value4}}</output><button
      type="button"
      {{on "click" this.listener4}}
    >Only juice</button></fieldset></template>
}

/** The values with `value` added when `checked`, and removed otherwise. */
function toggle<T>(values: readonly T[], value: T, checked: boolean): T[] {
  return checked ? values.concat([value]) : values.filter((each) => each !== value);
}
