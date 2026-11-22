import type { TOC } from "@ember/component/template-only";
import { htmlSafe } from "@ember/template";

export interface Entry {
  id: number;
  html: string;
}

export interface ChangelogProps {
  entries: Entry[];
}

export interface ChangelogSignature {
  Args: ChangelogProps;
  Element: HTMLElementTagNameMap["ul"];
}

const Changelog: TOC<ChangelogSignature> = <template><ul
    class="changelog"
    ...attributes
  >{{#each @entries key="id" as |entry|}}<li>{{htmlSafe entry.html}}</li>{{/each}}</ul></template>;

export default Changelog;
