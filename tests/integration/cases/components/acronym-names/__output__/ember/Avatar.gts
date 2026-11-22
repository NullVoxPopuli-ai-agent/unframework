import Component from "@glimmer/component";

export interface AvatarEvents {
  onPickedURL?: (url: string) => void;
}

export interface AvatarSignature {
  Args: { imageURL: string; userID: number } & AvatarEvents;
  Element: HTMLElementTagNameMap["button"];
}

export default class Avatar extends Component<AvatarSignature> {
  listener1 = () => this.args.onPickedURL?.(this.args.imageURL);

  <template><button
      type="button"
      data-user={{@userID}}
      {{on "click" this.listener1}}
      ...attributes
    >User {{@userID}}: {{@imageURL}}</button></template>
}
