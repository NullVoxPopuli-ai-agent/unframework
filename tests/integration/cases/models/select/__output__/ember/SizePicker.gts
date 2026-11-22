import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface SizePickerSignature {
  Element: HTMLElementTagNameMap["section"];
}

export default class SizePicker extends Component<SizePickerSignature> {
  @tracked size = "m";

  get value1() {
    return String(this.size) === "s";
  }

  get value2() {
    return String(this.size) === "m";
  }

  get value3() {
    return String(this.size) === "l";
  }

  listener1 = (event: Event) => {
    this.size = (event.currentTarget as HTMLSelectElement).value;
  };

  listener2 = () => (this.size = "l");

  <template><section
      aria-label="Size"
      ...attributes
    ><label>Size <select
      {{on "change" this.listener1}}
    ><option value="s" selected={{this.value1}}>Small</option><option
      value="m" selected={{this.value2}}
    >Medium</option><option value="l" selected={{this.value3}}>Large</option></select></label><output>Chosen: {{this.size}}</output><button
      type="button"
      {{on "click" this.listener2}}
    >Largest</button></section></template>
}
