import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface Fruit {
  name: string;
  colour: string;
}

export interface FruitPickerProps {
  fruits: Fruit[];
}

export interface FruitPickerEvents {
  onKept?: (name: string, colour: string) => void;
}

export interface FruitPickerSignature {
  Args: FruitPickerProps & FruitPickerEvents;
  Element: HTMLElementTagNameMap["section"];
}

export default class FruitPicker extends Component<FruitPickerSignature> {
  pick = (fruit: Fruit) => {
    this.selected = fruit;
  };

  keep = () => {
    const current = this.selected;
    if (!current) return;
    const copy = structuredClone(current);
    this.basket = [...this.basket, copy];
    this.args.onKept?.(copy.name, copy.colour);
  };

  @tracked selected: Fruit | null = null;

  @tracked basket: Fruit[] = [];

  value1 = (fruit: NonNullable<this["args"]["fruits"]>[number]) => fruit === this.selected;

  listener1 = (fruit: NonNullable<this["args"]["fruits"]>[number]) => () => this.pick(fruit);

  value2 = (fruit: NonNullable<this["basket"]>[number]) => `${fruit.name} (${fruit.colour})`;

  <template><section
      class="fruit-picker"
      aria-label="Fruit"
      ...attributes
    ><ul
      aria-label="Fruits"
    >{{#each @fruits key="name" as |fruit|}}<li><button
      type="button"
      aria-pressed={{enumeratedValue (this.value1 fruit)}}
      {{on "click" (this.listener1 fruit)}}
    >{{fruit.name}}</button></li>{{/each}}</ul><button
      type="button"
      {{on "click" this.keep}}
    >Keep a copy</button><ol
      aria-label="Basket"
    >{{#each this.basket key="@index" as |fruit|}}<li>{{this.value2 fruit}}</li>{{/each}}</ol></section></template>
}

/** An enumerated attribute's value: a boolean as its name, any other value as it is. */
function enumeratedValue<T>(value: T): Exclude<T, boolean> | "true" | "false" {
  return typeof value === "boolean"
    ? (String(value) as "true" | "false")
    : (value as Exclude<T, boolean>);
}
