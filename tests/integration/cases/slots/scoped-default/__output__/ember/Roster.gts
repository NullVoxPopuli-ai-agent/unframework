import type { TOC } from "@ember/component/template-only";
import Names from "./Names.gts";

export interface RosterSignature {
  Args: { names: string[] };
}

const Roster: TOC<RosterSignature> = <template><Names
    @names={{@names}}
  ><:default as |defaultProps|><b>{{defaultProps.item}}!</b></:default></Names></template>;

export default Roster;
