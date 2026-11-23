import Component from "@glimmer/component";
import Frame from "./Frame.gts";
import Mat from "./Mat.gts";

export interface GallerySignature {
  Args: { matted?: boolean };
  Element: HTMLElementTagNameMap["section"];
}

export default class Gallery extends Component<GallerySignature> {
  get matted() {
    return this.args.matted === undefined ? true : this.args.matted;
  }

  get value1() {
    return this.matted ? Mat : Frame;
  }

  <template><section
      ...attributes
    ><Frame><p class="caption" data-uf-9dc516fd-s="">A quiet harbour</p></Frame><Frame><:label as |labelProps|><p
      class="caption"
      data-uf-9dc516fd-s=""
    >{{labelProps.text}}</p></:label></Frame>{{#if (eq this.value1 Mat)}}<Mat><p
      class="caption"
      data-uf-09929c4a-s=""
      data-uf-9dc516fd-s=""
    >A matted print</p></Mat>{{else}}<Frame><p
      class="caption"
      data-uf-09929c4a-s=""
      data-uf-9dc516fd-s=""
    >A matted print</p></Frame>{{/if}}<p class="caption">Outside the frame</p></section></template>
}
