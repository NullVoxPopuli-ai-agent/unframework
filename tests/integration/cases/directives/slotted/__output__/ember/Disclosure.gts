import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface DisclosureSignature {
  Blocks: { default: [] };
  Element: HTMLElementTagNameMap["div"];
}

export default class Disclosure extends Component<DisclosureSignature> {
  @tracked open = false;

  listener1 = () => (this.open = !this.open);

  <template><div
      class="disclosure"
      ...attributes
    ><button
      type="button"
      aria-expanded={{enumeratedValue this.open}}
      {{on "click" this.listener1}}
    >Details</button>{{#if this.open}}<div class="body">{{yield}}</div>{{/if}}</div></template>
}

/** An enumerated attribute's value: a boolean as its name, any other value as it is. */
function enumeratedValue<T>(value: T): Exclude<T, boolean> | "true" | "false" {
  return typeof value === "boolean"
    ? (String(value) as "true" | "false")
    : (value as Exclude<T, boolean>);
}
