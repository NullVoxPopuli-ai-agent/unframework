import Component from "@glimmer/component";

export interface KeepAliveSignature {
  Args: { level: number };
  Element: HTMLElementTagNameMap["div"];
}

export default class KeepAlive extends Component<KeepAliveSignature> {
  get value1() {
    return this.args.level > 0;
  }

  get value2() {
    return this.args.level > 0 ? this.args.level - 1 : (undefined as never);
  }

  <template><div
      class="level"
      ...attributes
    ><span>Level {{@level}}</span>{{#if this.value1}}<KeepAlive @level={{this.value2}} />{{/if}}</div></template>
}
