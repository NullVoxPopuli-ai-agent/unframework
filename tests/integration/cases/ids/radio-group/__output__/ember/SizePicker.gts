import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { uniqueId } from "@ember/helper";

export interface SizePickerProps {
  legend: string;
  sizes: string[];
}

export interface SizePickerSignature {
  Args: SizePickerProps;
  Element: HTMLElementTagNameMap["fieldset"];
}

export default class SizePicker extends Component<SizePickerSignature> {
  choose = (size: string) => {
    this.picked = size;
  };

  readonly group = `uf-id-${uniqueId()}`;

  readonly hintId = `uf-id-${uniqueId()}`;

  @tracked picked = "";

  value1 = (index: number) => `${this.group}-${index}`;

  listener1 = (size: NonNullable<this["args"]["sizes"]>[number]) => () => this.choose(size);

  get value2() {
    return this.picked || "none";
  }

  <template><fieldset
      class="size-picker"
      aria-describedby={{this.hintId}}
      ...attributes
    ><legend>{{@legend}}</legend><p id={{this.hintId}}>Pick one size.</p>{{#each @sizes key="@identity" as |size index|}}<div
      class="size"
    ><input
      type="radio"
      id={{this.value1 index}}
      name={{this.group}}
      value={{size}}
      {{on "change" (this.listener1 size)}}
    ><label for={{this.value1 index}}>{{size}}</label></div>{{/each}}<output>{{this.value2}}</output></fieldset></template>
}
