import Component from "@glimmer/component";

export interface InboxMessage {
  id: string;
  subject: string;
}

export interface MessageListProps {
  messages: InboxMessage[];
  archived?: InboxMessage[];
  emptyText?: string;
}

export interface MessageListSignature {
  Args: MessageListProps;
  Element: HTMLElementTagNameMap["section"];
}

export default class MessageList extends Component<MessageListSignature> {
  get archived() {
    return this.args.archived === undefined ? [] : this.args.archived;
  }

  get emptyText() {
    return this.args.emptyText === undefined ? "Nothing here yet." : this.args.emptyText;
  }

  get value1() {
    return this.args.messages.length === 0;
  }

  get value2() {
    return this.archived.length === 0;
  }

  get value3() {
    return !(this.archived.length === 0) ? this.archived.length : undefined;
  }

  <template><section
      class="message-list"
      aria-label="Messages"
      ...attributes
    ><h2>Inbox</h2><ul>{{#each @messages key="id" as |message|}}<li>{{message.subject}}</li>{{/each}}</ul>{{#if this.value1}}<p>{{this.emptyText}}</p>{{/if}}<h2>Archive</h2><ul>{{#each this.archived key="id" as |message|}}<li>{{message.subject}}</li>{{/each}}</ul>{{#if this.value2}}<p>No archived messages.</p>{{else}}<p>{{this.value3}} archived</p>{{/if}}</section></template>
}
