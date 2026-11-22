import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface ListenerOrderSignature {
  Element: HTMLElementTagNameMap["section"];
}

export default class ListenerOrder extends Component<ListenerOrderSignature> {
  record = (line: string) => {
    this.log = [...this.log, line];
  };

  @tracked log: string[] = [];

  @tracked resets = 0;

  listener1 = () => this.record("save");

  listener2 = () => this.record("first save");

  listener3 = () => this.record("first send");

  listener4 = () => this.record("send");

  listener5 = () => this.record("reset");

  listener6 = () => (this.resets += 1);

  listener7 = () => this.record("toolbar");

  listener8 = () => this.record("inside");

  listener9 = () => this.record("panel capture");

  listener10 = (event: HTMLElementEventMap["click"]) => {
    event.stopPropagation();
    this.record("panel bubble");
  };

  listener11 = () => this.record("outside");

  listener12 = (event: HTMLElementEventMap["click"]) => {
    event.stopPropagation();
    this.record("stopped");
  };

  listener13 = () => this.record("pass");

  listener14 = () => this.record("claim once");

  listener15 = () => this.record("inner wheel");

  listener16 = () => this.record("outer wheel");

  <template><section
      class="listener-order"
      aria-label="Listener order"
      ...attributes
    ><div
      class="toolbar"
      role="presentation"
      {{on "click" this.listener7}}
    ><button
      type="button"
      {{on "click" this.listener1}}
      {{on "click" this.listener2 once=true}}
    >Save</button><button
      type="button"
      {{on "click" this.listener3 once=true}}
      {{on "click" this.listener4}}
    >Send</button><button
      type="button"
      {{on "click" this.listener5}}
      {{on "click" this.listener6 once=true}}
    >Reset</button></div><div
      class="panel"
      role="presentation"
      {{on "click" this.listener9 capture=true}}
      {{on "click" this.listener10}}
    ><button type="button" {{on "click" this.listener8}}>Inside</button></div><button
      type="button"
      {{on "click" this.listener11}}
    >Outside</button><div
      class="claim"
      role="presentation"
      {{on "click" this.listener14 once=true}}
    ><button type="button" {{on "click" this.listener12}}>Stop</button><button
      type="button"
      {{on "click" this.listener13}}
    >Pass</button></div><div
      class="outer-zone"
      role="group"
      aria-label="Outer zone"
      {{on "wheel" this.listener16}}
    ><div
      class="inner-zone"
      role="group"
      aria-label="Inner zone"
      {{on "wheel" this.listener15 passive=true}}
    >Scroll here</div></div><p>Resets: {{this.resets}}</p><ol
      aria-label="Log"
    >{{#each this.log key="@index" as |entry|}}<li>{{entry}}</li>{{/each}}</ol></section></template>
}
