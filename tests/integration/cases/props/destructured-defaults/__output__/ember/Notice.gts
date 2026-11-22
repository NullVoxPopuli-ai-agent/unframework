import Component from "@glimmer/component";

export interface NoticeProps {
  message: string;
  title?: string;
  tone?: "info" | "warning";
  priority?: number;
  expanded?: boolean;
  tags?: string[];
  author?: { name: string };
}

export interface NoticeSignature {
  Args: NoticeProps;
  Element: HTMLElementTagNameMap["section"];
}

export default class Notice extends Component<NoticeSignature> {
  get title() {
    return this.args.title === undefined ? "Notice" : this.args.title;
  }

  get tone() {
    return this.args.tone === undefined ? "info" : this.args.tone;
  }

  get priority() {
    return this.args.priority === undefined ? 1 : this.args.priority;
  }

  get expanded() {
    return this.args.expanded === undefined ? false : this.args.expanded;
  }

  get tags() {
    return this.args.tags === undefined ? ["general"] : this.args.tags;
  }

  get author() {
    return this.args.author === undefined ? { name: "System" } : this.args.author;
  }

  get value1() {
    return this.tags.join(", ");
  }

  <template><section
      class="notice"
      aria-label={{this.title}}
      data-tone={{this.tone}}
      ...attributes
    ><h2>{{this.title}}</h2><p>{{@message}}</p><details
      open={{this.expanded}}
    ><summary>Priority {{this.priority}}</summary><p>Tagged {{this.value1}}, posted by {{this.author.name}}.</p></details></section></template>
}
