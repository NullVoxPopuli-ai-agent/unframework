import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface SignupFormEvents {
  onSignup?: (fullName: string, email: string, plan: string, newsletter: boolean) => void;
}

export interface SignupFormSignature {
  Args: SignupFormEvents;
  Element: HTMLElementTagNameMap["form"];
}

export default class SignupForm extends Component<SignupFormSignature> {
  submit = (event: SubmitEvent) => {
    event.preventDefault();
    this.args.onSignup?.(this.fullName, this.email, this.plan, this.newsletter);
  };

  @tracked fullName = "";

  @tracked email = "";

  @tracked plan = "free";

  @tracked newsletter = false;

  @tracked focused = "none";

  listener1 = (event: HTMLElementEventMap["change"]) =>
    (this.fullName = (event.currentTarget as HTMLInputElement).value);

  listener2 = () => (this.focused = "name");

  listener3 = () => (this.focused = "none");

  listener4 = (event: HTMLElementEventMap["input"]) =>
    (this.email = (event.currentTarget as HTMLInputElement).value);

  listener5 = () => (this.focused = "email");

  listener6 = (event: HTMLElementEventMap["change"]) =>
    (this.plan = (event.currentTarget as HTMLSelectElement).value);

  listener7 = (event: HTMLElementEventMap["change"]) =>
    (this.newsletter = (event.currentTarget as HTMLInputElement).checked);

  get value1() {
    return `Name: ${this.fullName}; email: ${this.email}; plan: ${this.plan}; newsletter: ${this.newsletter ? "yes" : "no"}; focus: ${this.focused}`;
  }

  <template><form
      class="signup-form"
      aria-label="Sign up"
      {{on "submit" this.submit}}
      ...attributes
    ><label>Name<input
      name="name"
      {{on "change" this.listener1}}
      {{on "focus" this.listener2}}
      {{on "blur" this.listener3}}
    ></label><label>Email<input
      name="email"
      type="email"
      {{on "input" this.listener4}}
      {{on "focus" this.listener5}}
      {{on "blur" this.listener3}}
    ></label><label>Plan<select
      name="plan"
      {{on "change" this.listener6}}
    ><option value="free">Free</option><option value="pro">Pro</option></select></label><label><input
      name="newsletter"
      type="checkbox"
      {{on "change" this.listener7}}
    >Send me the newsletter</label><p role="status">{{this.value1}}</p><button
      type="submit"
    >Sign up</button></form></template>
}
