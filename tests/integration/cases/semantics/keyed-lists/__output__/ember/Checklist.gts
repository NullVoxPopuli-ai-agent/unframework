import Component from "@glimmer/component";

export interface Entry {
  id: string;
  label: string;
}

export interface ChecklistProps {
  entries: Entry[];
}

export interface ChecklistSignature {
  Args: ChecklistProps;
  Element: HTMLElementTagNameMap["ul"];
}

export default class Checklist extends Component<ChecklistSignature> {
  value1 = (entry: NonNullable<this["args"]["entries"]>[number]) => `note-${entry.id}`;

  value2 = (entry: NonNullable<this["args"]["entries"]>[number]) => `Note for ${entry.label}`;

  <template><ul
      class="checklist"
      ...attributes
    >{{#each @entries key="id" as |entry|}}<li><label>{{entry.label}}<input
      name={{this.value1 entry}}
      aria-label={{this.value2 entry}}
    ></label></li>{{/each}}</ul></template>
}
