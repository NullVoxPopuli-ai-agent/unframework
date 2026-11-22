import Component from "@glimmer/component";

export interface CountdownSignature {
  Args: { from: number };
  Element: HTMLElementTagNameMap["div"];
}

export default class Countdown extends Component<CountdownSignature> {
  get value1() {
    return this.args.from > 0;
  }

  get value2() {
    return this.args.from > 0 ? this.args.from - 1 : (undefined as never);
  }

  <template><div
      class="level"
      ...attributes
    ><span>{{@from}}</span>{{#if this.value1}}<Countdown @from={{this.value2}} />{{else}}<strong>Liftoff</strong>{{/if}}</div></template>
}
