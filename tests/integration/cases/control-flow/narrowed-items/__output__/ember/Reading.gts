import Component from "@glimmer/component";

export type Source =
  | { kind: "link"; id: string; title: string; href: string }
  | { kind: "book"; id: string; title: string; note?: string };

export interface ReadingProps {
  sources: Source[];
}

export interface ReadingEvents {
  onOpen?: (href: string) => void;
}

export interface ReadingSignature {
  Args: ReadingProps & ReadingEvents;
  Element: HTMLElementTagNameMap["ul"];
}

export default class Reading extends Component<ReadingSignature> {
  value1 = (index: number) => index + 1;

  value2 = (source: NonNullable<this["args"]["sources"]>[number]) =>
    source.kind === "book" && source.note ? ` (${source.note.trim()})` : "";

  value3 = (source: NonNullable<this["args"]["sources"]>[number]) => source.kind === "link";

  value4 = (source: NonNullable<this["args"]["sources"]>[number]) =>
    source.kind === "link" ? `Open ${source.title}` : undefined;

  listener1 = (source: NonNullable<this["args"]["sources"]>[number]) => () => {
    if (!(source.kind === "link")) return;
    return this.args.onOpen?.(source.href);
  };

  value5 = (source: NonNullable<this["args"]["sources"]>[number]) =>
    source.kind === "link" ? source.href : source.title;

  <template><ul
      class="reading"
      aria-label="Reading list"
      ...attributes
    >{{#each @sources key="id" as |source index|}}<li
      title={{this.value5 source}}
    >{{this.value1 index}}. {{source.title}}{{this.value2 source}}{{#if (this.value3 source)}}<button
      type="button"
      {{on "click" (this.listener1 source)}}
    >{{this.value4 source}}</button>{{/if}}</li>{{/each}}</ul></template>
}
