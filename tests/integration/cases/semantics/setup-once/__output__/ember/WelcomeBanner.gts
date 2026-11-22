import Component from "@glimmer/component";

export interface WelcomeBannerProps {
  name: string;
}

export interface WelcomeBannerSignature {
  Args: WelcomeBannerProps;
  Element: HTMLElementTagNameMap["section"];
}

export default class WelcomeBanner extends Component<WelcomeBannerSignature> {
  readonly greeting = `Welcome, ${this.args.name}`;

  readonly tips = ["Set up your profile", "Invite your team"];

  <template><section
      class="welcome-banner"
      aria-label="Welcome"
      ...attributes
    ><h2>{{this.greeting}}</h2><p>Signed in as {{@name}}</p><ul>{{#each this.tips key="@identity" as |tip|}}<li>{{tip}}</li>{{/each}}</ul></section></template>
}
