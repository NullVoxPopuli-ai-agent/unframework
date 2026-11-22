import Component from "@glimmer/component";

export interface LegendSignature {
  Args: { items: string[]; label: string };
  Blocks: { swatch: [props: { item: string }]; caption: [props: { item: string }] };
  Element: HTMLElementTagNameMap["ul"];
}

export default class Legend extends Component<LegendSignature> {
  value1 = (item: NonNullable<this["args"]["items"]>[number]) => ({ item });

  <template><ul
      aria-label={{@label}}
      ...attributes
    >{{#each @items key="@identity" as |item|}}<li><span>{{yield (this.value1 item) to="swatch"}}</span> <span>{{yield (this.value1 item) to="caption"}}</span></li>{{/each}}</ul></template>
}
