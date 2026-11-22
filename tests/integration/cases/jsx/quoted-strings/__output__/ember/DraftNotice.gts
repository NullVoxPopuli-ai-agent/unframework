import Component from "@glimmer/component";

export interface DraftNoticeProps {
  author: string;
  saved: boolean;
}

export interface DraftNoticeSignature {
  Args: DraftNoticeProps;
  Element: HTMLElementTagNameMap["section"];
}

export default class DraftNotice extends Component<DraftNoticeSignature> {
  get value1() {
    return `${this.args.author}'s avatar`;
  }

  get value2() {
    return this.args.saved ? "Saved" : 'Not "saved" yet';
  }

  get value3() {
    return this.args.saved ? "Saved" : "Don't forget to save";
  }

  get value4() {
    return this.args.saved
      ? `${this.args.author}'s draft is safe.`
      : `${this.args.author} says: "I'll save it later."`;
  }

  get value5() {
    return this.args.saved
      ? "Nothing to save"
      : `Press "Save" to keep ${this.args.author}'s changes`;
  }

  <template><section
      class="draft-notice"
      aria-label="Draft"
      ...attributes
    ><img
      src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='32' height='32'%3E%3Crect width='32' height='32' fill='%23345'/%3E%3C/svg%3E"
      alt={{this.value1}}
      width="32"
      height="32"
    ><p title={{this.value3}}>{{this.value2}}</p><p title={{this.value5}}>{{this.value4}}</p></section></template>
}
