import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface EventLogSignature {
  Element: HTMLElementTagNameMap["section"];
}

export default class EventLog extends Component<EventLogSignature> {
  record = (line: string) => {
    this.log = [...this.log, line];
  };

  changeVolume = (event: WheelEvent) => {
    if (event.deltaY < 0) {
      this.volume += 1;
    } else {
      this.volume -= 1;
    }
  };

  @tracked log: string[] = [];

  @tracked volume = 5;

  listener1 = () => this.record("button");

  listener2 = (event: HTMLElementEventMap["click"]) => {
    event.stopPropagation();
    this.record("stopped");
  };

  listener3 = () => this.record("panel capture");

  listener4 = () => this.record("panel bubble");

  listener5 = () => this.record("once");

  listener6 = (event: HTMLElementEventMap["click"]) => {
    event.stopPropagation();
    this.record("claimed");
  };

  listener7 = () => this.record("outer");

  <template><section
      class="event-log"
      aria-label="Event options"
      ...attributes
    ><div
      class="panel"
      role="presentation"
      {{on "click" this.listener3 capture=true}}
      {{on "click" this.listener4}}
    ><button type="button" {{on "click" this.listener1}}>Inside</button><button
      type="button"
      {{on "click" this.listener2}}
    >Stop here</button></div><button
      type="button"
      {{on "click" this.listener5 once=true}}
    >Only once</button><div
      class="reward"
      role="presentation"
      {{on "click" this.listener7}}
    ><button type="button" {{on "click" this.listener6 once=true}}>Claim the reward</button></div><div
      class="volume"
      role="group"
      aria-label="Volume"
      {{on "wheel" this.changeVolume passive=true}}
    ><output>{{this.volume}}</output></div><ol
      aria-label="Log"
    >{{#each this.log key="@index" as |entry|}}<li>{{entry}}</li>{{/each}}</ol></section></template>
}
