import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import Field, { type FieldEvents } from "./Field.gts";

export interface FormSignature {
  Args: { city: string };
  Element: HTMLElementTagNameMap["section"];
}

export default class Form extends Component<FormSignature> {
  clear = (label: string) => {
    this.cleared = label;
  };

  @tracked cleared = "nothing";

  listener1 = ((label) => this.clear(label.toUpperCase())) satisfies NonNullable<
    FieldEvents["onClear"]
  >;

  <template><section
      aria-label="Address"
      ...attributes
    ><Field @label="Street" @onClear={{this.clear}} /><Field
      @label={{@city}}
      @tone="warn"
      @onClear={{this.listener1}}
    /><output>Cleared: {{this.cleared}}</output></section></template>
}
