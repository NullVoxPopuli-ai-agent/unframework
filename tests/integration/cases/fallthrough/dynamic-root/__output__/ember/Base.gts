import Component from "@glimmer/component";

export interface BaseEvents {
  onPress?: () => void;
}

export interface BaseSignature {
  Args: { href?: string; disabled?: boolean; text: string } & BaseEvents;
  Element: HTMLElementTagNameMap["a"] | HTMLElementTagNameMap["button"];
}

export default class Base extends Component<BaseSignature> {
  press = (event: MouseEvent) => {
    event.preventDefault();
    this.args.onPress?.();
  };

  get value1() {
    return this.args.href ? "a" : "button";
  }

  <template>{{#if (eq this.value1 "a")}}<a
      href={{@href}}
      class="base"
      style="padding: 4px 8px"
      {{on "click" this.press}}
      ...attributes
    >{{@text}}</a>{{else}}<button
      disabled={{@disabled}}
      class="base"
      style="padding: 4px 8px"
      {{on "click" this.press}}
      ...attributes
    >{{@text}}</button>{{/if}}</template>
}
