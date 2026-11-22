import Component from "@glimmer/component";

interface LogLine {
  id: string;
  text: string;
}

export interface BuildLogProps {
  target: string;
  failed: boolean;
  lines?: LogLine[] | null;
  warnings?: string[];
}

export interface BuildLogSignature {
  Args: BuildLogProps;
  Element: HTMLElementTagNameMap["section"];
}

export default class BuildLog extends Component<BuildLogSignature> {
  get value1() {
    return this.args.lines ?? [];
  }

  get value2() {
    return this.args.warnings ?? [];
  }

  <template><section
      class="build-log"
      aria-label="Build log"
      ...attributes
    ><pre>$ make {{@target}}{{#if @failed}}<strong> (failed)</strong>{{/if}}&#10;{{#each this.value1 key="id" as |line|}}<code>{{line.text}}
</code>{{/each}}</pre><ul
      aria-label="Warnings"
    >{{#each this.value2 key="@identity" as |warning|}}<li>{{warning}}</li>{{/each}}</ul></section></template>
}
