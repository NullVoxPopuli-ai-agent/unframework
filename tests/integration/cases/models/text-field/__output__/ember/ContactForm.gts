import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface ContactFormSignature {
  Element: HTMLElementTagNameMap["form"];
}

export default class ContactForm extends Component<ContactFormSignature> {
  @tracked name = "Ada";

  @tracked email = "";

  listener1 = (event: Event) => {
    this.name = (event.currentTarget as HTMLInputElement).value;
  };

  listener2 = (event: Event) => {
    this.email = (event.currentTarget as HTMLInputElement).value;
  };

  get value1() {
    return this.email || "no address";
  }

  listener3 = () => (this.name = "Grace");

  <template><form
      aria-label="Contact"
      ...attributes
    ><label>Name <input value={{this.name}} {{on "input" this.listener1}}></label><label>Email <input
      type="email"
      value={{this.email}}
      {{on "input" this.listener2}}
    ></label><output>{{this.name}} at {{this.value1}}</output><button
      type="button"
      {{on "click" this.listener3}}
    >Use Grace</button></form></template>
}
