import Component from "@glimmer/component";

export interface MenuDish {
  id: string;
  name: string;
  price: number;
  vegetarian: boolean;
}

export interface MenuCourse {
  id: string;
  title: string;
  dishes: MenuDish[];
}

export interface MenuBoardProps {
  courses: MenuCourse[];
  closed: boolean;
}

export interface MenuBoardSignature {
  Args: MenuBoardProps;
  Element: HTMLElementTagNameMap["div"];
}

export default class MenuBoard extends Component<MenuBoardSignature> {
  value1 = (dish: NonNullable<NonNullable<this["args"]["courses"]>[number]["dishes"]>[number]) =>
    dish.price.toFixed(2);

  <template><div
      class="menu-board"
      ...attributes
    >{{#if @closed}}<p>The kitchen is closed.</p>{{else}}{{#each @courses key="id" as |course|}}<section
      aria-label={{course.title}}
    ><h2>{{course.title}}</h2><ul>{{#each course.dishes key="id" as |dish|}}<li>{{dish.name}}, {{this.value1 dish}}{{#if dish.vegetarian}}<span> (vegetarian)</span>{{/if}}</li>{{/each}}</ul></section>{{/each}}{{/if}}</div></template>
}
