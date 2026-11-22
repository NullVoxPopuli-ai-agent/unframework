import type { TOC } from "@ember/component/template-only";
import Notice from "./Notice.gts";

export interface BoardSignature {
  Args: { build: string };
  Element: HTMLElementTagNameMap["div"];
}

const Board: TOC<BoardSignature> = <template><div
    ...attributes
  ><Notice
    @label="Build"
  ><:default>Build {{@build}} failed.</:default><:action><a href="#logs">See the logs</a></:action></Notice><Notice
    @label="Deploy"
  /></div></template>;

export default Board;
