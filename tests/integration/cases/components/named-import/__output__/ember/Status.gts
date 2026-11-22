import type { TOC } from "@ember/component/template-only";
import { Badge } from "./Badge.gts";
import { Pill as Tag } from "./Pill.gts";

export interface StatusSignature {
  Args: { state: string };
  Element: HTMLElementTagNameMap["p"];
}

const Status: TOC<StatusSignature> = <template><p class="status" ...attributes><Badge @text="Build" /><Tag @text={{@state}} /></p></template>;

export default Status;
