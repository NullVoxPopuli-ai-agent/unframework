import Component from "@glimmer/component";

export interface FileInfo {
  path: string;
  size: number;
}

export interface FileRowProps {
  path: string;
  size: number;
}

export interface FileRowEvents {
  onRefresh?: () => void;
  onOpen?: (path: string) => void;
  onMove?: (from: string, to: string) => void;
  onPick?: (file: FileInfo) => void;
  onShare?: (path: string, note?: string) => void;
}

export interface FileRowSignature {
  Args: FileRowProps & FileRowEvents;
  Element: HTMLElementTagNameMap["div"];
}

export default class FileRow extends Component<FileRowSignature> {
  archive = () => {
    this.args.onMove?.(this.args.path, `archive/${this.args.path}`);
    this.args.onRefresh?.();
  };

  listener1 = () => this.args.onRefresh?.();

  listener2 = () => this.args.onOpen?.(this.args.path);

  listener3 = () => this.args.onPick?.({ path: this.args.path, size: this.args.size });

  listener4 = () => this.args.onShare?.(this.args.path);

  listener5 = () => this.args.onShare?.(this.args.path, "Please review");

  <template><div
      class="file-row"
      role="group"
      aria-label={{@path}}
      ...attributes
    ><span>{{@path}} ({{@size}} bytes)</span><button
      type="button"
      {{on "click" this.listener1}}
    >Refresh</button><button type="button" {{on "click" this.listener2}}>Open</button><button
      type="button"
      {{on "click" this.archive}}
    >Archive</button><button type="button" {{on "click" this.listener3}}>Select</button><button
      type="button"
      {{on "click" this.listener4}}
    >Share</button><button type="button" {{on "click" this.listener5}}>Share with a note</button></div></template>
}
