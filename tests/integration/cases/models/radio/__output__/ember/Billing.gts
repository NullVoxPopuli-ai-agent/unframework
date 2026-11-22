import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface BillingSignature {
  Element: HTMLElementTagNameMap["fieldset"];
}

export default class Billing extends Component<BillingSignature> {
  @tracked plan = "monthly";

  get value1() {
    return this.plan === "monthly";
  }

  listener1 = () => {
    this.plan = "monthly";
  };

  get value2() {
    return this.plan === "yearly";
  }

  listener2 = () => {
    this.plan = "yearly";
  };

  listener3 = () => (this.plan = "monthly");

  <template><fieldset
      ...attributes
    ><legend>Billing</legend><label><input
      type="radio"
      name="plan"
      value="monthly"
      checked={{this.value1}}
      {{on "change" this.listener1}}
    > Monthly</label><label><input
      type="radio"
      name="plan"
      value="yearly"
      checked={{this.value2}}
      {{on "change" this.listener2}}
    > Yearly</label><output>Plan: {{this.plan}}</output><button
      type="button"
      {{on "click" this.listener3}}
    >Reset</button></fieldset></template>
}
