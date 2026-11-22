import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface DeleteFileProps {
  fileName: string;
}

export interface DeleteFileEvents {
  onDeleted?: (fileName: string, copies: number) => void;
}

export interface DeleteFileSignature {
  Args: DeleteFileProps & DeleteFileEvents;
  Element: HTMLElementTagNameMap["section"];
}

export default class DeleteFile extends Component<DeleteFileSignature> {
  requestDelete = async () => {
    this.confirming = true;
    await new Promise<void>((resolve) => {
      this.resolveConfirmation = resolve;
    });
    this.confirming = false;
    this.args.onDeleted?.(this.args.fileName, this.copies);
  };

  addCopy = () => {
    this.copies += 1;
  };

  confirmDelete = () => {
    this.resolveConfirmation?.();
  };

  @tracked copies = 1;

  @tracked confirming = false;

  resolveConfirmation: (() => void) | undefined;

  get value1() {
    return this.copies === 1 ? "copy" : "copies";
  }

  <template><section
      class="delete-file"
      aria-label="File"
      ...attributes
    ><p>{{@fileName}}, {{this.copies}} {{this.value1}}</p><button
      type="button"
      {{on "click" this.addCopy}}
    >Add a copy</button>{{#if this.confirming}}<button
      type="button"
      {{on "click" this.confirmDelete}}
    >Confirm the deletion</button>{{else}}<button
      type="button"
      {{on "click" this.requestDelete}}
    >Delete</button>{{/if}}</section></template>
}
