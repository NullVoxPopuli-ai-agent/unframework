import { ref, useTemplateRef } from "@uxfront/unframework";

import Primary from "./Primary.uf.tsx";

export default function Toolbar() {
  const clicks = ref(0);
  const save = useTemplateRef<HTMLButtonElement>();
  return (
    <div role="toolbar" aria-label="Actions">
      <Primary
        ref={save}
        text="Save"
        id="save"
        aria-label="Save draft"
        onClick={() => clicks.value++}
      />
      <button type="button" onClick={() => save.value?.focus()}>
        Focus save
      </button>
      <p>Clicks: {clicks.value}</p>
    </div>
  );
}
