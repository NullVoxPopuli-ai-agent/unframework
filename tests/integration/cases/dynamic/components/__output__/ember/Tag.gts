import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import Card from "./Card.gts";
import Chip from "./Chip.gts";

export interface TagSignature {
  Args: { label: string };
  Element: HTMLElementTagNameMap["section"];
}

export default class Tag extends Component<TagSignature> {
  @tracked compact = true;

  get value1() {
    return this.compact ? Chip : Card;
  }

  get value2() {
    return this.compact ? "Expand" : "Compact";
  }

  listener1 = () => (this.compact = !this.compact);

  <template><section
      aria-label="Tag"
      ...attributes
    >{{#if (eq this.value1 Chip)}}<Chip @label={{@label}} />{{else}}<Card @label={{@label}} />{{/if}}<button
      type="button"
      {{on "click" this.listener1}}
    >{{this.value2}}</button></section></template>
}
