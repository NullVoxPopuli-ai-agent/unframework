import Component from "@glimmer/component";

export interface ListSignature {
  Args: { items: string[]; label: string };
  Blocks: { item: [props: { item: string; index: number }] };
  Element: HTMLElementTagNameMap["ul"];
}

export default class List extends Component<ListSignature> {
  value1 = (item: NonNullable<this["args"]["items"]>[number], index: number) => ({ item, index });

  <template><ul
      aria-label={{@label}}
      ...attributes
    >{{#each @items key="@identity" as |item index|}}<li>{{yield (this.value1 item index) to="item"}}</li>{{/each}}</ul></template>
}
