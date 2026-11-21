import { useTemplateRef } from "@uxfront/unframework";

// Exposes nothing, so a ref on it holds its root element. Its own template ref on that element
// still works: its focus listener fills the field through it.
export default function NameField({ label }: { label: string }) {
  const input = useTemplateRef<HTMLInputElement>();
  function fill() {
    if (input.value && !input.value.value) input.value.value = "Ada";
  }
  return <input ref={input} name="name" aria-label={label} onFocus={fill} />;
}
