import Component from "@glimmer/component";

export interface StatusIconProps {
  label: string;
  size?: number;
  colour?: string;
}

export interface StatusIconSignature {
  Args: StatusIconProps;
  Element: SVGSVGElement;
}

export default class StatusIcon extends Component<StatusIconSignature> {
  get size() {
    return this.args.size === undefined ? 24 : this.args.size;
  }

  get colour() {
    return this.args.colour === undefined ? "#1f6feb" : this.args.colour;
  }

  <template><svg
      class="status-icon"
      role="img"
      viewBox="0 0 24 24"
      width={{this.size}}
      height={{this.size}}
      fill="none"
      ...attributes
    ><title>{{@label}}</title><defs><linearGradient
      id="status-icon-fill"
      x1="0"
      y1="0"
      x2="1"
      y2="1"
    ><stop offset="0" stop-color={{this.colour}} /><stop offset="1" stop-color="#0b3d91" /></linearGradient></defs><circle
      cx="12"
      cy="12"
      r="10"
      fill="url(#status-icon-fill)"
    /><path
      d="M7 12.5l3 3 7-7"
      stroke="#ffffff"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
    /></svg></template>
}
