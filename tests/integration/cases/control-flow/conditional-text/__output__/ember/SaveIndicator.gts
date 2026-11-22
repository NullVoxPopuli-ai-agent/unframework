import Component from "@glimmer/component";

export interface SaveIndicatorProps {
  saving: boolean;
  changes: number;
  savedAt?: string;
}

export interface SaveIndicatorSignature {
  Args: SaveIndicatorProps;
  Element: HTMLElementTagNameMap["p"];
}

export default class SaveIndicator extends Component<SaveIndicatorSignature> {
  get value1() {
    return this.args.changes === 1 ? "1 change" : `${this.args.changes} changes`;
  }

  get value2() {
    return this.args.savedAt ? " at " + this.args.savedAt : undefined;
  }

  <template><p
      class="save-indicator"
      role="status"
      ...attributes
    >{{#if @saving}}<em>Saving</em>{{else}}Saved{{/if}}, {{this.value1}}{{#if @savedAt}}<time
      datetime={{@savedAt}}
    >{{this.value2}}</time>{{else}} just now{{/if}}</p></template>
}
