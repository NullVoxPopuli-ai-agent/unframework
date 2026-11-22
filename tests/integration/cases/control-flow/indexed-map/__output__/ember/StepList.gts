import Component from "@glimmer/component";

export interface StepListProps {
  title: string;
  steps: string[];
}

export interface StepListSignature {
  Args: StepListProps;
  Element: HTMLElementTagNameMap["ol"];
}

export default class StepList extends Component<StepListSignature> {
  value1 = (index: number) => index + 1;

  <template><ol
      class="step-list"
      aria-label={{@title}}
      ...attributes
    >{{#each @steps key="@index" as |step index|}}<li
      data-step={{this.value1 index}}
    >Step {{this.value1 index}}: {{step}}</li>{{/each}}</ol></template>
}
