import Component from "@glimmer/component";

export interface ListSignature {
  Args: { items: string[] };
  Blocks: { item: [props: { item: string }] };
  Element: HTMLElementTagNameMap["ol"];
}

export default class List extends Component<ListSignature> {
  value1 = (item: NonNullable<this["args"]["items"]>[number]) => ({ item });

  <template><ol
      ...attributes
    >{{#each @items key="@identity" as |item|}}<li>{{yield (this.value1 item) to="item"}}</li>{{/each}}</ol></template>
}
