import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import Row from "./Row.gts";

export interface Task {
  id: number;
  name: string;
  done: boolean;
}

export interface TasksSignature {
  Args: { initial: Task[] };
  Element: HTMLElementTagNameMap["div"];
}

export default class Tasks extends Component<TasksSignature> {
  add = () => {
    this.tasks = [...this.tasks, { id: this.tasks.length + 1, name: "Water plants", done: false }];
  };

  finish = (id: number) => {
    this.tasks = this.tasks.map((task) => (task.id === id ? { ...task, done: true } : task));
  };

  @tracked tasks = this.args.initial;

  listener1 = () => this.finish(1);

  <template><div
      ...attributes
    ><div
      role="list"
      aria-label="Tasks"
    >{{#each this.tasks key="id" as |task|}}<Row @name={{task.name}} @done={{task.done}} />{{/each}}</div><button
      type="button"
      {{on "click" this.add}}
    >Add a task</button><button
      type="button"
      {{on "click" this.listener1}}
    >Finish the first</button></div></template>
}
