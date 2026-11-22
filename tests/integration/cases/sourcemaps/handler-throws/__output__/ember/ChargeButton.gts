import Component from "@glimmer/component";

export interface ChargeButtonSignature {
  Element: HTMLElementTagNameMap["button"];
}

export default class ChargeButton extends Component<ChargeButtonSignature> {
  charge = () => {
    throw new Error("The card was declined");
  };

  <template><button type="button" {{on "click" this.charge}} ...attributes>Charge</button></template>
}
