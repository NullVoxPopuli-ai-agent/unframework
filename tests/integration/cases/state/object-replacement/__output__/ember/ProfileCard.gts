import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface Profile {
  name: string;
  title: string;
  available: boolean;
}

export interface ProfileCardProps {
  initial: Profile;
}

export interface ProfileCardSignature {
  Args: ProfileCardProps;
  Element: HTMLElementTagNameMap["article"];
}

export default class ProfileCard extends Component<ProfileCardSignature> {
  rename = (name: string) => {
    this.profile = { ...this.profile, name };
  };

  toggleAvailability = () => {
    this.profile = { ...this.profile, available: !this.profile.available };
  };

  @tracked profile = this.args.initial;

  get value1() {
    return this.profile.available ? "Available" : "Away";
  }

  listener1 = () => this.rename("Ada King");

  <template><article
      class="profile-card"
      aria-label="Profile"
      ...attributes
    ><h2>{{this.profile.name}}</h2><p>{{this.profile.title}}</p><p role="status">{{this.value1}}</p><button
      type="button"
      {{on "click" this.listener1}}
    >Use married name</button><button
      type="button"
      aria-pressed={{enumeratedValue this.profile.available}}
      {{on "click" this.toggleAvailability}}
    >Available</button></article></template>
}

/** An enumerated attribute's value: a boolean as its name, any other value as it is. */
function enumeratedValue<T>(value: T): Exclude<T, boolean> | "true" | "false" {
  return typeof value === "boolean"
    ? (String(value) as "true" | "false")
    : (value as Exclude<T, boolean>);
}
