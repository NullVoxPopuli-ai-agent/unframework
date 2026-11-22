import type { TOC } from "@ember/component/template-only";
import Panel from "./Panel.gts";

export interface GreetingSignature {
  Args: { name: string };
}

const Greeting: TOC<GreetingSignature> = <template><Panel
    @title="Welcome"
  ><p>Hello, <strong>{{@name}}</strong>!</p><p>Your children render in the panel.</p></Panel></template>;

export default Greeting;
