import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import Member from "./Member.gts";

export interface RosterSignature {
  Args: { ids: string[] };
  Element: HTMLElementTagNameMap["section"];
}

export default class Roster extends Component<RosterSignature> {
  @tracked lead = true;

  @tracked guest = false;

  listener1 = () => (this.lead = !this.lead);

  listener2 = () => (this.guest = !this.guest);

  <template><section
      class="roster"
      aria-label="Roster"
      ...attributes
    ><button type="button" {{on "click" this.listener1}}>Switch lead</button><button
      type="button"
      {{on "click" this.listener2}}
    >Toggle guest</button><ul>{{#each @ids key="@identity" as |id|}}<Member @id={{id}} />{{/each}}{{#if this.lead}}<Member
      @id="ada"
    />{{else}}<Member @id="linus" />{{/if}}{{#if this.guest}}<Member @id="hopper" />{{/if}}</ul></section></template>
}
