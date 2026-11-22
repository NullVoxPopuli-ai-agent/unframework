import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface ReplyBoxSignature {
  Element: HTMLElementTagNameMap["section"];
}

export default class ReplyBox extends Component<ReplyBoxSignature> {
  accept = (event: KeyboardEvent) => {
    event.preventDefault();
    this.suggesting = false;
    this.accepted += 1;
  };

  @tracked started = false;

  @tracked suggesting = false;

  @tracked accepted = 0;

  listener1 = (event: HTMLElementEventMap["keydown"]) => {
    if (event.key === "Enter") event.preventDefault();
    this.started = true;
  };

  get value1() {
    return this.started ? "Started" : "Not started";
  }

  listener2 = (event: HTMLElementEventMap["keydown"]) => {
    if (this.suggesting && event.key === "Enter") this.accept(event);
  };

  listener3 = () => (this.suggesting = !this.suggesting);

  <template><section
      class="reply-box"
      aria-label="Reply"
      ...attributes
    ><label>Message<textarea name="message" {{on "keydown" this.listener1 once=true}}></textarea></label><p>{{this.value1}}</p><label>Answer<textarea
      name="answer"
      {{on "keydown" this.listener2}}
    ></textarea></label><button
      type="button"
      aria-pressed={{enumeratedValue this.suggesting}}
      {{on "click" this.listener3}}
    >Suggestions</button><p>Accepted: {{this.accepted}}</p></section></template>
}

/** An enumerated attribute's value: a boolean as its name, any other value as it is. */
function enumeratedValue<T>(value: T): Exclude<T, boolean> | "true" | "false" {
  return typeof value === "boolean"
    ? (String(value) as "true" | "false")
    : (value as Exclude<T, boolean>);
}
