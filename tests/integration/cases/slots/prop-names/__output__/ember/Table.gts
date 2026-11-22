import Component from "@glimmer/component";

export interface Person {
  id: string;
  name: string;
}

export interface TableSignature {
  Args: { people: Person[] };
  Blocks: { row: [props: { name: string; "data-id": string; index: number }] };
  Element: HTMLElementTagNameMap["ol"];
}

export default class Table extends Component<TableSignature> {
  value1 = (person: NonNullable<this["args"]["people"]>[number], index: number) => ({
    name: person.name,
    "data-id": person.id,
    index,
  });

  <template><ol
      aria-label="People"
      ...attributes
    >{{#each @people key="id" as |person index|}}<li>{{yield (this.value1 person index) to="row"}}</li>{{/each}}</ol></template>
}
