import type { TOC } from "@ember/component/template-only";

export interface FileTransferProps {
  fileName: string;
  percent: number;
  paused: boolean;
  eta?: string;
}

export interface FileTransferSignature {
  Args: FileTransferProps;
  Element: HTMLElementTagNameMap["div"];
}

const FileTransfer: TOC<FileTransferSignature> = <template><div
    class="file-transfer"
    ...attributes
  ><svg
    class="file-transfer-progress"
    role="img"
    viewBox="0 0 36 36"
    width="36"
    height="36"
  ><title>{{@fileName}}: {{@percent}}% sent. {{@eta}}</title><circle
    cx="18"
    cy="18"
    r="16"
    fill="none"
    stroke="#0969da"
    stroke-width="4"
  /></svg><svg
    class="file-transfer-state"
    role="img"
    viewBox="0 0 16 16"
    width="16"
    height="16"
  ><title>{{#if @paused}}Transfer paused{{else}}Sending {{@fileName}}{{/if}}</title><rect
    x="2"
    y="2"
    width="12"
    height="12"
    rx="2"
    fill="#1a7f37"
  /></svg></div></template>;

export default FileTransfer;
