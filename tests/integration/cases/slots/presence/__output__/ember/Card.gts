import type { TOC } from "@ember/component/template-only";

export interface CardSignature {
  Args: { label: string };
  Blocks: { title: []; default: [] };
  Element: HTMLElementTagNameMap["section"];
}

const Card: TOC<CardSignature> = <template><section
    class="card"
    aria-label={{@label}}
    ...attributes
  >{{#if (has-block "title")}}<header class="title">{{yield to="title"}}</header>{{/if}}{{#if (has-block)}}<div
    class="body"
  >{{yield}}</div>{{else}}<p>Empty card</p>{{/if}}</section></template>;

export default Card;
