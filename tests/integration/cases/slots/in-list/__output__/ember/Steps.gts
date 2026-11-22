import type { TOC } from "@ember/component/template-only";

export interface StepsSignature {
  Args: { steps: string[] };
  Blocks: { marker: [] };
  Element: HTMLElementTagNameMap["ol"];
}

const Steps: TOC<StepsSignature> = <template><ol
    class="steps"
    ...attributes
  >{{#each @steps key="@identity" as |step|}}<li>{{yield to="marker"}}{{step}}</li>{{/each}}</ol></template>;

export default Steps;
