import Component from "@glimmer/component";

export interface ContactCardProps {
  name: string;
  jobTitle?: string;
  team?: string;
  pronouns?: string;
  phone?: string | null;
}

export interface ContactCardSignature {
  Args: ContactCardProps;
  Element: HTMLElementTagNameMap["article"];
}

export default class ContactCard extends Component<ContactCardSignature> {
  get value1() {
    return this.args.phone ?? "not listed";
  }

  <template><article
      class="contact-card"
      aria-label={{@name}}
      data-team={{@team}}
      ...attributes
    ><h2 title={{@pronouns}}>{{@name}}</h2><p>{{@jobTitle}}</p><p>Phone: {{this.value1}}</p></article></template>
}
