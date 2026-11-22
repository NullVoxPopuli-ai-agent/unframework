import Component from "@glimmer/component";
import { isDestroying } from "@ember/destroyable";
import { renderSettled } from "@ember/renderer";

export interface ChartSignature {
  Element: HTMLElementTagNameMap["p"];
}

export default class Chart extends Component<ChartSignature> {
  #mounted = false;

  /** Called at the template's end: the hooks run once the component has rendered. */
  onMounted = (): undefined => {
    if (!this.#mounted) {
      this.#mounted = true;
      afterRender(this, () => {
        throw new Error("The chart could not start");
      });
    }
    return undefined;
  };

  <template><p ...attributes>Chart</p>{{(this.onMounted)}}</template>
}

/** Runs `run` once the render settles, unless its component is gone by then. */
function afterRender(owner: object, run: () => unknown): void {
  void renderSettled().then(() => {
    if (!isDestroying(owner)) void run();
  });
}
