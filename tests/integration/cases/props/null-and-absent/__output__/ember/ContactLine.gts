import Component from "@glimmer/component";

export interface ContactLineProps {
  name: string;
  phone?: string | null;
  verified?: boolean | null;
}

export interface ContactLineSignature {
  Args: ContactLineProps;
  Element: HTMLElementTagNameMap["section"];
}

export default class ContactLine extends Component<ContactLineSignature> {
  get value1() {
    return this.args.phone === null ? "withheld" : (this.args.phone ?? "not given yet");
  }

  get value2() {
    return this.args.phone === null ? "withheld" : this.args.phone;
  }

  get value3() {
    return this.args.verified === null
      ? "Verification pending"
      : this.args.verified
        ? "Verified"
        : "Not verified";
  }

  <template><section
      class="contact-line"
      aria-label={{@name}}
      ...attributes
    ><p data-phone={{this.value2}}>Phone: {{this.value1}}</p><p>{{this.value3}}</p></section></template>
}
