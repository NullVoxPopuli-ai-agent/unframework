import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface FilterPanelSignature {
  Element: HTMLElementTagNameMap["section"];
}

export default class FilterPanel extends Component<FilterPanelSignature> {
  @tracked open = false;

  @tracked colour: string | null = null;

  @tracked note: string | null = null;

  listener1 = () => {
    if (!this.open) return;
    return (this.open = false);
  };

  listener2 = () => {
    if (!!this.open) return;
    return (this.open = true);
  };

  listener3 = () => (this.colour = "Red");

  listener4 = () => (this.colour = "Blue");

  listener5 = () => {
    if (!this.open) return;
    this.colour = null;
    this.open = false;
  };

  get value1() {
    return this.colour ? `Colour: ${this.colour}` : undefined;
  }

  get value2() {
    return this.colour ? `Clear ${this.colour}` : undefined;
  }

  listener6 = () => {
    if (!this.colour) return;
    return (this.colour = null);
  };

  get value3() {
    return this.note === null;
  }

  listener7 = () => {
    if (!(this.note === null)) return;
    return (this.note = "");
  };

  listener8 = (event: HTMLElementEventMap["input"]) => {
    if (!!(this.note === null)) return;
    return (this.note = (event.currentTarget as HTMLInputElement).value);
  };

  listener9 = (event: HTMLElementEventMap["keydown"]) => {
    if (!!(this.note === null)) return;
    if (event.key === "Escape") {
      this.note = null;
    }
  };

  get value4() {
    return !(this.note === null) ? `Draft: "${this.note}"` : undefined;
  }

  <template><section
      class="filter-panel"
      aria-label="Filters"
      ...attributes
    >{{#if this.open}}<button
      type="button"
      aria-expanded="true"
      {{on "click" this.listener1}}
    >Hide colours</button>{{else}}<button
      type="button"
      aria-expanded="false"
      {{on "click" this.listener2}}
    >Show colours</button>{{/if}}{{#if this.open}}<div
      class="colours"
    ><button type="button" {{on "click" this.listener3}}>Red</button><button
      type="button"
      {{on "click" this.listener4}}
    >Blue</button><button type="button" {{on "click" this.listener5}}>Reset</button></div>{{/if}}{{#if this.colour}}<div
      class="selection"
    ><p>{{this.value1}}</p><button
      type="button"
      {{on "click" this.listener6}}
    >{{this.value2}}</button></div>{{else}}<p>No colour</p>{{/if}}{{#if this.value3}}<button
      type="button"
      {{on "click" this.listener7}}
    >Add a note</button>{{else}}<div
      class="note"
    ><label>Note<input {{on "input" this.listener8}} {{on "keydown" this.listener9}}></label><p>{{this.value4}}</p></div>{{/if}}</section></template>
}
