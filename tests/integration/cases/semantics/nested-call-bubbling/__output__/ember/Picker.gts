import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { renderSettled } from "@ember/renderer";

export interface PickerEvents {
  onDone?: (step: number, status: string) => void;
}

export interface PickerSignature {
  Args: PickerEvents;
  Element: HTMLElementTagNameMap["section"];
}

export default class Picker extends Component<PickerSignature> {
  record = (line: string) => {
    this.log = [...this.log, line];
  };

  pick = (name: string) => {
    this.selected = name;
    this.hits += 1;
  };

  report = () => {
    this.record(`picked ${this.selected} #${this.hits}`);
  };

  load = async () => {
    this.status = "loading";
    await Promise.resolve();
    this.step += 1;
  };

  run = async () => {
    this.step += 1;
    await this.load();
    this.status = `loaded ${this.step}`;
    await renderSettled();
    this.args.onDone?.(this.step, this.status);
  };

  start = () => {
    void this.run();
    this.status = "started";
  };

  @tracked selected = "none";

  @tracked hits = 0;

  @tracked log: string[] = [];

  @tracked status = "idle";

  @tracked step = 0;

  listener1 = () => this.pick("alpha");

  listener2 = () => this.pick("beta");

  <template><section
      class="picker"
      aria-label="Picker"
      ...attributes
    ><div
      class="choices"
      role="presentation"
      {{on "click" this.report}}
    ><button type="button" {{on "click" this.listener1}}>Alpha</button><button
      type="button"
      {{on "click" this.listener2}}
    >Beta</button></div><ol
      aria-label="Log"
    >{{#each this.log key="@index" as |entry|}}<li>{{entry}}</li>{{/each}}</ol><p
      role="status"
    >{{this.status}}</p><button type="button" {{on "click" this.start}}>Start</button></section></template>
}
