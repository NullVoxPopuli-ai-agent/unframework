import type { TOC } from "@ember/component/template-only";

export interface CalloutProps {
  heading: string;
  body: string;
}

export interface CalloutSignature {
  Args: CalloutProps;
  Element: HTMLElementTagNameMap["aside"];
}

const Callout: TOC<CalloutSignature> = <template><aside
    class="callout"
    aria-label={{@heading}}
    style="--callout-accent: #1f4d7a; border-left: 4px solid var(--callout-accent); padding: 8px 12px; color: #1a1a1a"
    ...attributes
  ><p style="margin: 0; font-weight: 700">{{@heading}}</p><p style="margin: 4px 0 0">{{@body}}</p></aside></template>;

export default Callout;
