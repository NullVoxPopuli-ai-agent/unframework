import type { TOC } from "@ember/component/template-only";

export interface SummaryProps {
  name: string;
  plan: string;
  seats: number;
}

export interface SummarySignature {
  Args: SummaryProps;
  Element: HTMLElementTagNameMap["div"];
}

const Summary: TOC<SummarySignature> = <template><div
    class="summary"
    style="display: table; border-spacing: 8px 4px"
    ...attributes
  ><div style="display: table-caption; font-weight: 700">Account</div><div
    style="display: table-row"
  ><span style="display: table-cell">Name</span><span style="display: table-cell">{{@name}}</span></div><div
    style="display: table-row"
  ><span style="display: table-cell">Plan</span><span
    style="display: table-cell"
  >{{@plan}} for {{@seats}} seats</span></div><p>Billed to <span
    style="display: table-cell; padding: 0 4px"
  >{{@name}}</span> monthly.</p></div></template>;

export default Summary;
