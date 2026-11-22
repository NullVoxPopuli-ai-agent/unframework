import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import Notice from "./Notice.gts";

export interface InboxSignature {
  Args: { unread: number };
  Element: HTMLElementTagNameMap["div"];
}

export default class Inbox extends Component<InboxSignature> {
  @tracked count = this.args.unread;

  get value1() {
    return this.count > 0;
  }

  get value2() {
    return this.count > 0 ? `${this.count} unread` : (undefined as never);
  }

  listener1 = () => (this.count = 0);

  <template><div
      class="inbox"
      ...attributes
    >{{#if this.value1}}<Notice @text={{this.value2}} @tone="info" />{{else}}<Notice
      @text="All read"
      @tone="quiet"
    />{{/if}}<button type="button" {{on "click" this.listener1}}>Mark all read</button></div></template>
}
