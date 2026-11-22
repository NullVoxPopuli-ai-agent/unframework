import Component from "@glimmer/component";
import Legend, { type LegendSignature } from "./Legend.gts";

export interface ChartSignature {
  Args: { series: string[] };
  Element: HTMLElementTagNameMap["div"];
}

export default class Chart extends Component<ChartSignature> {
  value1 = (swatchProps: LegendSignature["Blocks"]["swatch"][0]) => swatchProps.item.slice(0, 1);

  value2 = (captionProps: LegendSignature["Blocks"]["caption"][0]) =>
    captionProps.item.toUpperCase();

  <template><div
      ...attributes
    ><Legend
      @items={{@series}}
      @label="Series"
    ><:swatch as |swatchProps|><b>{{this.value1 swatchProps}}</b></:swatch><:caption as |captionProps|><i>{{captionProps.item}}</i></:caption></Legend><Legend
      @items={{@series}}
      @label="Captions"
    ><:caption as |captionProps|><span>{{this.value2 captionProps}}</span></:caption></Legend></div></template>
}
