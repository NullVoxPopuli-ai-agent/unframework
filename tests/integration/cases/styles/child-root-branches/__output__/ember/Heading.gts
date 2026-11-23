import Component from "@glimmer/component";

export interface HeadingSignature {
  Args: { big: boolean; text: string };
  Element: HTMLElementTagNameMap["h2"] | HTMLElementTagNameMap["h3"];
}

export default class Heading extends Component<HeadingSignature> {
  get value1() {
    return this.args.big ? "h2" : "h3";
  }

  <template>{{#if (eq this.value1 "h2")}}<h2 class="heading" ...attributes>{{@text}}</h2>{{else}}<h3
      class="heading"
      ...attributes
    >{{@text}}</h3>{{/if}}</template>
}
