import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface ProfileFieldsEvents {
  onFirstNickname?: (nickname: string) => void;
}

export interface ProfileFieldsSignature {
  Args: ProfileFieldsEvents;
  Element: HTMLElementTagNameMap["section"];
}

export default class ProfileFields extends Component<ProfileFieldsSignature> {
  record = (line: string) => {
    this.log = [...this.log, line];
  };

  hold = (event: MouseEvent) => {
    event.preventDefault();
    this.record("locked click");
  };

  @tracked log: string[] = [];

  @tracked nickname = "";

  @tracked cardFocuses = 0;

  @tracked cardBlurs = 0;

  listener1 = () => this.record("name focus");

  listener2 = () => this.record("name blur");

  listener3 = () => this.record("group focusin");

  listener4 = () => this.record("group focusout");

  listener5 = (event: HTMLElementEventMap["change"]) =>
    (this.nickname = (event.currentTarget as HTMLInputElement).value);

  listener6 = (event: HTMLElementEventMap["change"]) =>
    this.args.onFirstNickname?.((event.currentTarget as HTMLInputElement).value);

  listener7 = () => this.record("public click");

  listener8 = () => this.record("public input");

  listener9 = () => this.record("public change");

  listener10 = () => this.record("locked change");

  get value1() {
    return this.cardFocuses > this.cardBlurs ? "Card focused" : "Card not focused";
  }

  listener11 = () => this.record("card button");

  listener12 = () => this.cardFocuses++;

  listener13 = () => this.cardBlurs++;

  <template><section
      class="profile-fields"
      aria-label="Profile"
      ...attributes
    ><div
      class="name-group"
      role="group"
      aria-label="Name fields"
      {{on "focusin" this.listener3}}
      {{on "focusout" this.listener4}}
    ><label>Name<input name="name" {{on "focus" this.listener1}} {{on "blur" this.listener2}}></label></div><label>Nickname<input
      name="nickname"
      {{on "change" this.listener5}}
      {{on "change" this.listener6 once=true}}
    ></label><p>Nickname: {{this.nickname}}</p><label><input
      type="checkbox"
      name="public"
      {{on "click" this.listener7}}
      {{on "input" this.listener8}}
      {{on "change" this.listener9}}
    >Public profile</label><label><input
      type="checkbox"
      name="locked"
      {{on "click" this.hold}}
      {{on "change" this.listener10}}
    >Locked</label><div
      class="card"
      role="group"
      aria-label="Card"
      tabindex="-1"
      {{on "focus" this.listener12}}
      {{on "blur" this.listener13}}
    ><p>{{this.value1}}</p><p>Card blurs: {{this.cardBlurs}}</p><button
      type="button"
      {{on "click" this.listener11}}
    >Inside the card</button></div><ol
      aria-label="Log"
    >{{#each this.log key="@index" as |entry|}}<li>{{entry}}</li>{{/each}}</ol></section></template>
}
