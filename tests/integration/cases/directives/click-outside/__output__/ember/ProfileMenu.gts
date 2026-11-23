import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { vClickOutside } from "./vClickOutside.ts";

export interface ProfileMenuEvents {
  onClosed?: () => void;
}

export interface ProfileMenuSignature {
  Args: ProfileMenuEvents;
  Element: HTMLElementTagNameMap["section"];
}

export default class ProfileMenu extends Component<ProfileMenuSignature> {
  close = () => {
    if (!this.open) return;
    this.open = false;
    this.args.onClosed?.();
  };

  @tracked open = false;

  listener1 = () => (this.open = !this.open);

  <template><section
      class="profile-menu"
      aria-label="Profile"
      ...attributes
    ><div
      class="menu"
      {{vClickOutside this.close}}
    ><button
      type="button"
      aria-expanded={{enumeratedValue this.open}}
      {{on "click" this.listener1}}
    >Account</button>{{#if this.open}}<ul
      aria-label="Account actions"
    ><li><button type="button">Settings</button></li><li><button type="button">Sign out</button></li></ul>{{/if}}</div><p>Outside the menu</p></section></template>
}

/** An enumerated attribute's value: a boolean as its name, any other value as it is. */
function enumeratedValue<T>(value: T): Exclude<T, boolean> | "true" | "false" {
  return typeof value === "boolean"
    ? (String(value) as "true" | "false")
    : (value as Exclude<T, boolean>);
}
