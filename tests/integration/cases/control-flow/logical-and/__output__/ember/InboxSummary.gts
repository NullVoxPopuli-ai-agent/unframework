import Component from "@glimmer/component";

export interface InboxSummaryProps {
  folder: string;
  unread: number;
  flagged: number;
  signature: string;
}

export interface InboxSummarySignature {
  Args: InboxSummaryProps;
  Element: HTMLElementTagNameMap["section"];
}

export default class InboxSummary extends Component<InboxSummarySignature> {
  get value1() {
    return this.args.folder || "Inbox";
  }

  get value2() {
    return this.args.unread > 0 && this.args.flagged > 0;
  }

  <template><section
      class="inbox-summary"
      aria-label="Inbox summary"
      ...attributes
    ><h2>{{this.value1}}</h2>{{#if @unread}}<p>{{@unread}} unread</p>{{/if}}{{#if @flagged}}<p>{{@flagged}} flagged</p>{{/if}}{{#if this.value2}}<p>Some unread messages are flagged.</p>{{/if}}{{#if @folder}}<p>Filed under {{@folder}}</p>{{/if}}{{#if @signature}}<p
      class="inbox-signature"
    >{{@signature}}</p>{{/if}}</section></template>
}
