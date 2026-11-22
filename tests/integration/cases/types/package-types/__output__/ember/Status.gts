import type { TOC } from "@ember/component/template-only";
import type { Labelled } from "./types";
import type { TimeInterval } from "rxjs";

type StatusProps = TimeInterval<string> & Labelled;

export interface StatusSignature {
  Args: StatusProps;
  Element: HTMLElementTagNameMap["p"];
}

const Status: TOC<StatusSignature> = <template><p ...attributes>{{@label}}: {{@value}} after {{@interval}} ms</p></template>;

export default Status;
