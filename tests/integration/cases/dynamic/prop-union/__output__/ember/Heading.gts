import type { TOC } from "@ember/component/template-only";

export interface HeadingSignature {
  Args: { tag: "h1" | "h2" | "h3"; text: string };
  Element: HTMLElementTagNameMap["h1"] | HTMLElementTagNameMap["h2"] | HTMLElementTagNameMap["h3"];
}

const Heading: TOC<HeadingSignature> = <template>{{#if (eq @tag "h1")}}<h1 class="heading" ...attributes>{{@text}}</h1>{{else if (eq @tag "h2")}}<h2
    class="heading"
    ...attributes
  >{{@text}}</h2>{{else}}<h3 class="heading" ...attributes>{{@text}}</h3>{{/if}}</template>;

export default Heading;
