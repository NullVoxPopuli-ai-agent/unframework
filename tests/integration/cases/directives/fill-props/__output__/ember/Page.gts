import Component from "@glimmer/component";
import Picker, { type PickerSignature } from "./Picker.gts";
import { vTrace } from "./vTrace.ts";

export interface PageSignature {
  Element: HTMLElementTagNameMap["section"];
}

export default class Page extends Component<PageSignature> {
  value1 = (optionProps: PickerSignature["Blocks"]["option"][0]) =>
    `option-${optionProps.option.id}`;

  <template><section
      class="page"
      aria-label="Page"
      ...attributes
    ><Picker><:option as |optionProps|><span
      data-name={{this.value1 optionProps}}
      {{vTrace optionProps.option.label}}
    >{{optionProps.option.label}}</span></:option></Picker></section></template>
}
