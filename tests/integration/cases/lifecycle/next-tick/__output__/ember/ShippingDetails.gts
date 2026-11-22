import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { capabilities, setModifierManager } from "@ember/modifier";
import { renderSettled } from "@ember/renderer";
import type { ModifierLike } from "@glint/template";

export interface ShippingDetailsEvents {
  onToggled?: (items: number) => void;
}

export interface ShippingDetailsSignature {
  Args: ShippingDetailsEvents;
  Element: HTMLElementTagNameMap["section"];
}

export default class ShippingDetails extends Component<ShippingDetailsSignature> {
  toggle = async () => {
    this.open = !this.open;
    await renderSettled();
    this.args.onToggled?.(this.details?.childElementCount ?? 0);
  };

  @tracked open = false;

  @tracked details: HTMLUListElement | null = null;

  <template><section
      class="shipping-details"
      aria-label="Shipping"
      ...attributes
    ><button
      type="button"
      aria-expanded={{enumeratedValue this.open}}
      {{on "click" this.toggle}}
    >Shipping details</button>{{#if this.open}}<ul
      {{templateRef this "details"}}
    ><li>Ships in two days</li><li>Free returns</li><li>Tracked delivery</li></ul>{{/if}}</section></template>
}

/** An enumerated attribute's value: a boolean as its name, any other value as it is. */
function enumeratedValue<T>(value: T): Exclude<T, boolean> | "true" | "false" {
  return typeof value === "boolean"
    ? (String(value) as "true" | "false")
    : (value as Exclude<T, boolean>);
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
