import Component from "@glimmer/component";
import Section from "./Section.gts";

export interface PageSignature {
  Args: { name: string };
  Element: HTMLElementTagNameMap["article"];
}

export default class Page extends Component<PageSignature> {
  get value1() {
    return `About ${this.args.name}`;
  }

  get value2() {
    return `Write to ${this.args.name}.`;
  }

  <template><article
      aria-label="Profile"
      ...attributes
    ><Section @title={{this.value1}} @body="Three components deep." /><Section
      @title="Contact"
      @body={{this.value2}}
    /></article></template>
}
