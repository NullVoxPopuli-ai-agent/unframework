import Component from "@glimmer/component";

type LookupResult = { ok: true; match: string } | { ok: false; error: string };

export interface FilterSummaryProps {
  tags: string | string[];
  limit: number | string;
  result: LookupResult;
}

export interface FilterSummarySignature {
  Args: FilterSummaryProps;
  Element: HTMLElementTagNameMap["section"];
}

export default class FilterSummary extends Component<FilterSummarySignature> {
  get value1() {
    return Array.isArray(this.args.tags) ? this.args.tags.join(", ") : this.args.tags;
  }

  get value2() {
    return typeof this.args.limit === "number"
      ? this.args.limit.toFixed(0)
      : this.args.limit.toLowerCase();
  }

  <template><section
      class="filter-summary"
      aria-label="Filters"
      ...attributes
    ><p>Tags: {{this.value1}}</p><p>Limit: {{this.value2}}</p>{{#if @result.ok}}<p>Found {{@result.match}}</p>{{else}}<p>No match: {{@result.error}}</p>{{/if}}</section></template>
}
