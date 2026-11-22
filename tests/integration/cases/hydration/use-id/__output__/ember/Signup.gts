import type { TOC } from "@ember/component/template-only";
import Field from "./Field.gts";

export interface SignupProps {
  name: string;
  email: string;
}

export interface SignupSignature {
  Args: SignupProps;
  Element: HTMLElementTagNameMap["form"];
}

const Signup: TOC<SignupSignature> = <template><form
    class="signup"
    aria-label="Sign up"
    ...attributes
  ><Field @label={{@name}} @hint="As it appears on your card." /><Field
    @label={{@email}}
    @hint="We send the receipt here."
  /></form></template>;

export default Signup;
