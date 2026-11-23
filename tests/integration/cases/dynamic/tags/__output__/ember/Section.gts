import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface SectionSignature {
  Args: { title: string };
  Element: HTMLElementTagNameMap["article"];
}

export default class Section extends Component<SectionSignature> {
  @tracked nested = false;

  get value1() {
    return this.nested ? "h3" : "h2";
  }

  get value2() {
    return this.nested ? "Lift" : "Nest";
  }

  listener1 = () => (this.nested = !this.nested);

  <template><article
      ...attributes
    >{{#if (eq this.value1 "h3")}}<h3 class="title">{{@title}}</h3>{{else}}<h2
      class="title"
    >{{@title}}</h2>{{/if}}<button
      type="button"
      {{on "click" this.listener1}}
    >{{this.value2}}</button></article></template>
}
