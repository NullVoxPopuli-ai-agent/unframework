import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface TermsSignature {
  Element: HTMLElementTagNameMap["section"];
}

export default class Terms extends Component<TermsSignature> {
  @tracked agreed = false;

  listener1 = (event: Event) => {
    this.agreed = (event.currentTarget as HTMLInputElement).checked;
  };

  get value1() {
    return this.agreed ? "Agreed" : "Not agreed";
  }

  listener2 = () => (this.agreed = !this.agreed);

  <template><section
      aria-label="Terms"
      ...attributes
    ><label><input type="checkbox" checked={{this.agreed}} {{on "change" this.listener1}}> I agree</label><output>{{this.value1}}</output><button
      type="button"
      {{on "click" this.listener2}}
    >Toggle</button></section></template>
}
