import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { htmlSafe } from "@ember/template";

export interface GlossaryProps {
  terms: string[];
  definitions: string[];
}

export interface GlossarySignature {
  Args: GlossaryProps;
  Element: HTMLElementTagNameMap["section"];
}

export default class Glossary extends Component<GlossarySignature> {
  next = () => {
    this.index = (this.index + 1) % this.args.terms.length;
  };

  @tracked index = 0;

  get definition() {
    return this.args.definitions[this.index] ?? "";
  }

  get value1() {
    return this.args.terms[this.index];
  }

  <template><section
      class="glossary"
      aria-label="Glossary"
      ...attributes
    ><h2>{{this.value1}}</h2><div class="definition">{{htmlSafe this.definition}}</div><button
      type="button"
      {{on "click" this.next}}
    >Next term</button></section></template>
}
