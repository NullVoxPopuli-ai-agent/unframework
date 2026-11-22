import Component from "@glimmer/component";
import List, { type ListSignature } from "./List.gts";

export interface RankingSignature {
  Args: { names: string[] };
  Element: HTMLElementTagNameMap["div"];
}

export default class Ranking extends Component<RankingSignature> {
  value1 = (itemProps: ListSignature["Blocks"]["item"][0]) => itemProps.index + 1;

  value2 = (entry: ListSignature["Blocks"]["item"][0]) => entry.item.slice(0, 1);

  <template><div
      ...attributes
    ><List
      @items={{@names}}
      @label="Podium"
    ><:item as |itemProps|><span>{{this.value1 itemProps}}. <b>{{itemProps.item}}</b></span></:item></List><List
      @items={{@names}}
      @label="Initials"
    ><:item as |entry|><i>{{this.value2 entry}}</i></:item></List></div></template>
}
