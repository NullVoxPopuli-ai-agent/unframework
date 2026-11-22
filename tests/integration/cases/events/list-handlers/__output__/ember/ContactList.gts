import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface Contact {
  id: string;
  name: string;
}

export interface ContactListProps {
  initial: Contact[];
}

export interface ContactListEvents {
  onChoose?: (id: string, position: number) => void;
  onRemoved?: (name: string) => void;
}

export interface ContactListSignature {
  Args: ContactListProps & ContactListEvents;
  Element: HTMLElementTagNameMap["section"];
}

export default class ContactList extends Component<ContactListSignature> {
  pick = (entry: Contact, position: number) => {
    this.chosen = entry.id;
    this.args.onChoose?.(entry.id, position);
  };

  drop = (entry: Contact) => {
    this.contacts = this.contacts.filter((other) => other.id !== entry.id);
    this.args.onRemoved?.(entry.name);
  };

  @tracked contacts = this.args.initial;

  @tracked chosen: string | undefined = undefined;

  value1 = (contact: NonNullable<this["contacts"]>[number]) => this.chosen === contact.id;

  listener1 = (contact: NonNullable<this["contacts"]>[number], index: number) => () =>
    this.pick(contact, index);

  value2 = (contact: NonNullable<this["contacts"]>[number]) => `Remove ${contact.name}`;

  listener2 = (contact: NonNullable<this["contacts"]>[number]) => () => this.drop(contact);

  get value3() {
    return this.chosen ?? "nobody";
  }

  <template><section
      class="contact-list"
      aria-label="Contacts"
      ...attributes
    ><ul>{{#each this.contacts key="id" as |contact index|}}<li><button
      type="button"
      aria-pressed={{enumeratedValue (this.value1 contact)}}
      {{on "click" (this.listener1 contact index)}}
    >{{contact.name}}</button><button
      type="button"
      aria-label={{this.value2 contact}}
      {{on "click" (this.listener2 contact)}}
    >Remove</button></li>{{/each}}</ul><p role="status">Chosen: {{this.value3}}</p></section></template>
}

/** An enumerated attribute's value: a boolean as its name, any other value as it is. */
function enumeratedValue<T>(value: T): Exclude<T, boolean> | "true" | "false" {
  return typeof value === "boolean"
    ? (String(value) as "true" | "false")
    : (value as Exclude<T, boolean>);
}
