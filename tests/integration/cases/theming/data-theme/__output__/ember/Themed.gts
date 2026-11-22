import Component from "@glimmer/component";
import "virtual:styleframe.css";

export interface ThemedSignature {
  Args: { text: string; dark?: boolean };
  Element: HTMLElementTagNameMap["section"];
}

export default class Themed extends Component<ThemedSignature> {
  get dark() {
    return this.args.dark === undefined ? false : this.args.dark;
  }

  get value1() {
    return this.dark ? "dark" : "light";
  }

  <template><section
      data-theme={{this.value1}}
      class="_padding:md _background-color:surface _color:text"
      ...attributes
    >{{@text}}</section></template>
}
