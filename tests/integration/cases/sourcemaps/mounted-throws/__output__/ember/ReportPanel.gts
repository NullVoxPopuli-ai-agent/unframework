import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import Chart from "./Chart.gts";

export interface ReportPanelSignature {
  Element: HTMLElementTagNameMap["section"];
}

export default class ReportPanel extends Component<ReportPanelSignature> {
  show = () => {
    this.open = true;
  };

  @tracked open = false;

  <template><section
      aria-label="Report"
      ...attributes
    ><button type="button" {{on "click" this.show}}>Show the chart</button>{{#if this.open}}<Chart />{{/if}}</section></template>
}
