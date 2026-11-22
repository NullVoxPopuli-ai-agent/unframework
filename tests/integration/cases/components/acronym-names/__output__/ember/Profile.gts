import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import Avatar, { type AvatarEvents } from "./Avatar.gts";

export interface ProfileSignature {
  Element: HTMLElementTagNameMap["div"];
}

export default class Profile extends Component<ProfileSignature> {
  @tracked picked = "none";

  listener1 = ((url) => (this.picked = url)) satisfies NonNullable<AvatarEvents["onPickedURL"]>;

  <template><div
      ...attributes
    ><Avatar @imageURL="/a.png" @userID={{7}} @onPickedURL={{this.listener1}} /><output>Picked: {{this.picked}}</output></div></template>
}
