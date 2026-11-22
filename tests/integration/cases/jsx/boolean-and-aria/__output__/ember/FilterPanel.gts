import Component from "@glimmer/component";

export interface FilterPanelProps {
  heading: string;
  hint: string;
  category: string;
  expanded: boolean;
  inStockOnly: boolean;
  locked: boolean;
  mandatory: boolean;
  loading: boolean;
  invalid?: boolean;
  current?: "page" | "step";
}

export interface FilterPanelSignature {
  Args: FilterPanelProps;
  Element: HTMLElementTagNameMap["section"];
}

export default class FilterPanel extends Component<FilterPanelSignature> {
  get value1() {
    return this.args.loading ? "Loading results" : "Results ready";
  }

  <template><section
      class="filter-panel"
      aria-label={{@heading}}
      data-category={{@category}}
      data-layout="stacked"
      ...attributes
    ><button
      type="button"
      aria-expanded={{enumeratedValue @expanded}}
      aria-describedby="filter-panel-hint"
    >Price filters</button><p id="filter-panel-hint">{{@hint}}</p><details
      open={{@expanded}}
    ><summary>Price range</summary><label>Minimum price<input
      type="number"
      name="min-price"
      required={{@mandatory}}
      disabled={{@locked}}
      aria-invalid={{enumeratedValue @invalid}}
    ></label></details><button
      type="button"
      aria-pressed={{enumeratedValue @inStockOnly}}
      disabled={{@locked}}
    >In stock only</button><nav
      aria-label="Filter steps"
    ><a href="#filters" aria-current={{enumeratedValue @current}}>Filters</a></nav><p
      role="status"
      aria-live="polite"
      aria-busy={{enumeratedValue @loading}}
    >{{this.value1}}</p></section></template>
}

/** An enumerated attribute's value: a boolean as its name, any other value as it is. */
function enumeratedValue<T>(value: T): Exclude<T, boolean> | "true" | "false" {
  return typeof value === "boolean"
    ? (String(value) as "true" | "false")
    : (value as Exclude<T, boolean>);
}
