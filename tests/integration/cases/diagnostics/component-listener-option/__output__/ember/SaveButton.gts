import Component from "@glimmer/component";

export interface SaveButtonEvents {
  onSave?: () => void;
}

export interface SaveButtonSignature {
  Args: SaveButtonEvents;
  Element: HTMLElementTagNameMap["button"];
}

export class SaveButton extends Component<SaveButtonSignature> {
  listener1 = () => this.args.onSave?.();

  <template><button type="button" {{on "click" this.listener1}} ...attributes>Save</button></template>
}
