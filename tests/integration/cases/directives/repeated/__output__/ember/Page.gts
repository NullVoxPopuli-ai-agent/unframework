import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { capabilities, setModifierManager } from "@ember/modifier";
import type { ModifierLike } from "@glint/template";
import Choice from "./Choice.gts";
import List from "./List.gts";
import Wrapper from "./Wrapper.gts";
import { vTrace } from "./vTrace.ts";

export interface PageSignature {
  Element: HTMLElementTagNameMap["section"];
}

export default class Page extends Component<PageSignature> {
  @tracked label = "first";

  @tracked note: HTMLParagraphElement | null = null;

  @tracked noted = "";

  get value1() {
    return ["a", "b"];
  }

  listener1 = () => (this.noted = this.note?.getAttribute("data-name") ?? "");

  listener2 = () => (this.label = "second");

  <template><section
      class="page"
      aria-label="Page"
      ...attributes
    ><Wrapper><:row><span data-name="row" {{vTrace this.label}}>Row</span></:row></Wrapper><Choice><:body><em
      data-name="body"
      {{vTrace this.label}}
    >Body</em></:body></Choice><List
      @items={{this.value1}}
    ><:item as |itemProps|><strong
      data-name="item"
      {{vTrace this.label}}
    >{{itemProps.item}}</strong></:item></List><p
      {{templateRef this "note"}}
      data-name="note"
      {{vTrace this.label}}
    >Note</p><output>{{this.noted}}</output><button
      type="button"
      {{on "click" this.listener1}}
    >Check</button><button type="button" {{on "click" this.listener2}}>Rename</button></section></template>
}

/** A modifier that sets a member of its component to its element while the element is rendered. */
const templateRef = setModifierManager(
  () => ({
    capabilities: capabilities("3.22"),
    createModifier: () => ({}),
    installModifier(
      _state: object,
      element: Element,
      { positional }: { positional: readonly unknown[] },
    ) {
      Reflect.set(positional[0] as object, positional[1] as string, element);
    },
    updateModifier() {},
    destroyModifier(_state: object, { positional }: { positional: readonly unknown[] }) {
      Reflect.set(positional[0] as object, positional[1] as string, null);
    },
  }),
  {},
) as unknown as ModifierLike<{
  Element: Element;
  Args: { Positional: [owner: object, name: string] };
}>;
