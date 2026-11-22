import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface SeatPickerProps {
  pricePerSeat: number;
}

export interface SeatPickerEvents {
  onQuote?: (seats: number, total: number, summary: string) => void;
}

export interface SeatPickerSignature {
  Args: SeatPickerProps & SeatPickerEvents;
  Element: HTMLElementTagNameMap["section"];
}

export default class SeatPicker extends Component<SeatPickerSignature> {
  addSeat = () => {
    this.seats += 1;
    this.args.onQuote?.(this.seats, this.total, this.summary);
  };

  addGroupWithGuide = () => {
    this.seats += 4;
    const groupTotal = this.total;
    this.seats += 1;
    this.args.onQuote?.(this.seats, this.total, `${this.summary}, ${groupTotal} without the guide`);
  };

  @tracked seats = 1;

  get total() {
    return this.seats * this.args.pricePerSeat;
  }

  get summary() {
    return this.seats === 1 ? `1 seat for ${this.total}` : `${this.seats} seats for ${this.total}`;
  }

  <template><section
      class="seat-picker"
      aria-label="Seats"
      ...attributes
    ><p role="status">{{this.summary}}</p><button
      type="button"
      {{on "click" this.addSeat}}
    >Add a seat</button><button
      type="button"
      {{on "click" this.addGroupWithGuide}}
    >Add a group and a guide</button></section></template>
}
