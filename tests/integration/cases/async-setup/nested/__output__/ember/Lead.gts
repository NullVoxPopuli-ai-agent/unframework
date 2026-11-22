import type { TOC } from "@ember/component/template-only";
import Member from "./Member.gts";

export interface LeadSignature {
  Args: { id: string };
}

const Lead: TOC<LeadSignature> = <template><Member @id={{@id}} /></template>;

export default Lead;
