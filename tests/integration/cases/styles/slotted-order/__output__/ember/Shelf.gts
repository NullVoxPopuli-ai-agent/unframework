import Component from "@glimmer/component";
import Amber from "./Amber.gts";
import Blue from "./Blue.gts";

export interface ShelfSignature {
  Element: HTMLElementTagNameMap["section"];
}

export default class Shelf extends Component<ShelfSignature> {
  readonly items = [
    { label: "Warm", warm: true },
    { label: "Cool", warm: false },
  ];

  value1 = (item: NonNullable<this["items"]>[number]) => (item.warm ? Amber : Blue);

  <template><section
      ...attributes
    ><Blue><p class="caption" data-uf-721c504a-s="">In blue</p></Blue><Amber><p
      class="caption"
      data-uf-c97301b3-s=""
    >In amber</p></Amber>{{#each this.items key="label" as |item|}}<div>{{#if (eq (this.value1 item) Amber)}}<Amber><p
      class="caption"
      data-uf-c97301b3-s=""
      data-uf-721c504a-s=""
    >{{item.label}}</p></Amber>{{else}}<Blue><p
      class="caption"
      data-uf-c97301b3-s=""
      data-uf-721c504a-s=""
    >{{item.label}}</p></Blue>{{/if}}</div>{{/each}}</section></template>
}
