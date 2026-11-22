import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

interface User {
  name: string;
}

export interface AccountMenuProps {
  owner?: User;
}

export interface AccountMenuEvents {
  onGreeted?: (name: string) => void;
}

export interface AccountMenuSignature {
  Args: AccountMenuProps & AccountMenuEvents;
  Element: HTMLElementTagNameMap["section"];
}

export default class AccountMenu extends Component<AccountMenuSignature> {
  start = () => {
    this.step = "account";
  };

  signIn = () => {
    this.user = { name: "Ada" };
  };

  signOut = () => {
    this.user = null;
  };

  greet = (name: string) => {
    this.args.onGreeted?.(name);
  };

  @tracked step = "intro";

  @tracked user: User | null = null;

  get value1() {
    return this.step === "intro";
  }

  get value2() {
    return this.user === null;
  }

  get value3() {
    return this.user !== null;
  }

  get value4() {
    return this.user !== null ? this.user.name : undefined;
  }

  get value5() {
    return this.args.owner ? `Greet ${this.args.owner.name}` : undefined;
  }

  listener1 = () => {
    if (!this.args.owner) return;
    return this.greet(this.args.owner.name);
  };

  <template><section
      class="account-menu"
      aria-label="Account"
      ...attributes
    >{{#if this.value1}}<button type="button" {{on "click" this.start}}>Start</button>{{else}}{{#if this.value2}}<button
      type="button"
      {{on "click" this.signIn}}
    >Sign in</button>{{else}}<button type="button" {{on "click" this.signOut}}>Sign out</button>{{/if}}{{/if}}{{#if this.value3}}<p>Signed in as {{this.value4}}</p>{{else}}<p>Nobody signed in</p>{{/if}}{{#if @owner}}<button
      type="button"
      {{on "click" this.listener1}}
    >{{this.value5}}</button>{{else}}<p>No owner</p>{{/if}}</section></template>
}
