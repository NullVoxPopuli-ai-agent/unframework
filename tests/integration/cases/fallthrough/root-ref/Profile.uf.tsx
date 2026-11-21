import { useTemplateRef } from "@uxfront/unframework";

import NameField from "./NameField.uf.tsx";

export default function Profile() {
  const name = useTemplateRef<HTMLInputElement>();
  return (
    <form aria-label="Profile">
      <NameField ref={name} label="Name" />
      <button type="button" onClick={() => name.value?.focus()}>
        Edit name
      </button>
    </form>
  );
}
