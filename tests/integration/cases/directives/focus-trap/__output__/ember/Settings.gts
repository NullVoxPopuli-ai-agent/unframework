import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { vFocusTrap } from "./vFocusTrap.ts";

export interface SettingsSignature {
  Element: HTMLElementTagNameMap["section"];
}

export default class Settings extends Component<SettingsSignature> {
  close = () => {
    this.open = false;
  };

  onKeydown = (event: KeyboardEvent) => {
    if (event.key === "Escape") this.close();
  };

  @tracked open = false;

  listener1 = () => (this.open = true);

  <template><section
      class="settings"
      aria-label="Settings"
      ...attributes
    ><button type="button" {{on "click" this.listener1}}>Open</button>{{#if this.open}}<div
      role="dialog"
      aria-label="Preferences"
      tabindex="-1"
      class="dialog"
      {{vFocusTrap this.open}}
      {{on "keydown" this.onKeydown}}
    ><button type="button">Theme</button><button type="button">Language</button><button
      type="button"
      {{on "click" this.close}}
    >Close</button></div>{{/if}}</section></template>
}
