import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import Toast from "./Toast.gts";

export interface InboxSignature {
  Element: HTMLElementTagNameMap["section"];
}

export default class Inbox extends Component<InboxSignature> {
  @tracked shown = true;

  get value1() {
    return this.shown ? "Hide" : "Show";
  }

  listener1 = () => (this.shown = !this.shown);

  <template><section
      aria-label="Inbox"
      ...attributes
    ><button type="button" {{on "click" this.listener1}}>{{this.value1}}</button>{{#if this.shown}}<Toast />{{/if}}</section></template>
}
