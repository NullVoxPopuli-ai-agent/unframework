import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface TallyEvents {
  onTotal?: (value: number) => void;
  onSteps?: (values: number[]) => void;
  onLogged?: (entries: string[]) => void;
}

export interface TallySignature {
  Args: TallyEvents;
  Element: HTMLElementTagNameMap["section"];
}

export default class Tally extends Component<TallySignature> {
  addTwice = () => {
    this.count++;
    this.count++;
    this.args.onTotal?.(this.count);
  };

  addFive = () => {
    this.count += 5;
    this.args.onTotal?.(this.count);
  };

  countUp = () => {
    const seen: number[] = [];
    for (let step = 0; step < 3; step++) {
      this.count += 1;
      seen.push(this.count);
    }
    this.args.onSteps?.(seen);
  };

  addTen = () => {
    this.count += 10;
  };

  addTenAndReport = () => {
    this.addTen();
    this.args.onTotal?.(this.count);
  };

  logCapture = () => {
    this.trail = [...this.trail, "capture"];
  };

  logBubble = () => {
    this.trail = [...this.trail, "bubble"];
    this.args.onLogged?.(this.trail);
  };

  @tracked count = 0;

  @tracked trail: string[] = [];

  get value1() {
    return this.trail.join(" then ");
  }

  <template><section
      class="tally"
      aria-label="Tally"
      ...attributes
    ><p role="status">Count: {{this.count}}</p><button
      type="button"
      {{on "click" this.addTwice}}
    >Add two</button><button type="button" {{on "click" this.addFive}}>Add five</button><button
      type="button"
      {{on "click" this.countUp}}
    >Count up three</button><button
      type="button"
      {{on "click" this.addTenAndReport}}
    >Add ten</button><button
      type="button"
      {{on "click" this.logCapture capture=true}}
      {{on "click" this.logBubble}}
    >Log the phases</button><p>Phases: {{this.value1}}</p></section></template>
}
