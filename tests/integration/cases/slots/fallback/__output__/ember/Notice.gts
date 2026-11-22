import type { TOC } from "@ember/component/template-only";

export interface NoticeSignature {
  Args: { label: string };
  Blocks: { default: []; action: [] };
  Element: HTMLElementTagNameMap["div"];
}

const Notice: TOC<NoticeSignature> = <template><div
    role="note"
    aria-label={{@label}}
    class="notice"
    ...attributes
  ><p>{{#if (has-block)}}{{yield}}{{else}}<em>Nothing to report.</em>{{/if}}</p>{{#if (has-block "action")}}{{yield to="action"}}{{else}}<span
    class="muted"
  >No action</span>{{/if}}</div></template>;

export default Notice;
