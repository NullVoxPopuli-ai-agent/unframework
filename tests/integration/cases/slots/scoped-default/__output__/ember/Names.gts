import Component from "@glimmer/component";

export interface NamesSignature {
  Args: { names: string[] };
  Blocks: { default: [props: { item: string }] };
  Element: HTMLElementTagNameMap["ul"];
}

export default class Names extends Component<NamesSignature> {
  value1 = (item: NonNullable<this["args"]["names"]>[number]) => ({ item });

  <template><ul
      aria-label="Names"
      ...attributes
    >{{#each @names key="@identity" as |item|}}<li>{{yield (this.value1 item)}}</li>{{/each}}</ul></template>
}
