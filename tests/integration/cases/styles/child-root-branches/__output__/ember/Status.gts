import type { TOC } from "@ember/component/template-only";

export interface StatusSignature {
  Args: { busy: boolean; text: string };
}

const Status: TOC<StatusSignature> = <template>{{#if @busy}}<span class="badge" role="status">Saving</span>{{else}}<button
    type="button"
    class="badge"
  >{{@text}}</button>{{/if}}</template>;

export default Status;
