import Component from "@glimmer/component";
import "./Frame.uf.tsx.css";

export interface FrameSignature {
  Blocks: { default: []; label: [props: { text: string }] };
  Element: HTMLElementTagNameMap["figure"];
}

export default class Frame extends Component<FrameSignature> {
  get value1() {
    return { text: "Harbour at dusk" };
  }

  <template><figure
      class="frame"
      data-uf-9dc516fd=""
      ...attributes
    >{{yield}}{{yield this.value1 to="label"}}</figure></template>
}
