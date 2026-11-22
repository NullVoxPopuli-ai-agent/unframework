import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

type TagStates = { selected?: boolean; muted?: boolean };

export interface TagListProps {
  label: string;
  tags: string[];
  states: TagStates;
  extra?: string[];
}

export interface TagListSignature {
  Args: TagListProps;
  Element: HTMLElementTagNameMap["div"];
}

export default class TagList extends Component<TagListSignature> {
  expand = () => {
    this.expanded = !this.expanded;
  };

  @tracked expanded = false;

  get value1() {
    return classNames("tag", this.args.tags, this.args.states, this.expanded && "tag-open");
  }

  get value2() {
    return classNames(this.args.tags);
  }

  get value3() {
    return classNames(this.args.extra, this.expanded ? ["tag-wide", "tag-tall"] : []);
  }

  <template><div
      class="tag-list"
      ...attributes
    ><span class={{this.value1}}>{{@label}}</span><span class={{this.value2}}>Plain</span><span
      class={{this.value3}}
    >Extra</span><button type="button" {{on "click" this.expand}}>Expand</button></div></template>
}

/** A class as clsx builds it: strings, arrays and toggle objects, empty tokens left out. */
function classNames(...values: unknown[]): string | undefined {
  const tokens: string[] = [];
  const add = (value: unknown): void => {
    if (!value) return;
    if (typeof value === "string" || typeof value === "number") tokens.push(String(value));
    else if (Array.isArray(value)) for (const each of value) add(each);
    else if (typeof value === "object") {
      for (const [name, on] of Object.entries(value)) if (on) tokens.push(name);
    }
  };
  for (const value of values) add(value);
  return tokens.length ? tokens.join(" ") : undefined;
}
