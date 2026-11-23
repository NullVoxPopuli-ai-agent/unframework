import Component from "@glimmer/component";
import { vMark } from "./vMark.ts";

export interface TagProps {
  name: string;
}

export interface TagSignature {
  Args: TagProps;
  Element: HTMLElementTagNameMap["em"];
}

export default class Tag extends Component<TagSignature> {
  get value1() {
    return `tag ${this.args.name}`;
  }

  <template><em class="tag" {{vMark this.value1}} ...attributes>#{{@name}}</em></template>
}
