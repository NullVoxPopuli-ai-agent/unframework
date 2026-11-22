import type { TOC } from "@ember/component/template-only";
import Card from "./Card.gts";

export interface CardsSignature {
  Element: HTMLElementTagNameMap["div"];
}

const Cards: TOC<CardsSignature> = <template><div
    class="cards"
    ...attributes
  ><Card
    @label="Full"
  ><:default><p>Sunny, 21°</p></:default><:title><h3>Weather</h3></:title></Card><Card
    @label="Bare"
  /></div></template>;

export default Cards;
