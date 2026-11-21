import { onMounted, useTemplateRef } from "@uxfront/unframework";

// Exposes nothing, so a ref on it holds its root element. Its own template ref on that element
// still works: it fills the field once mounted.
export default function NameField({ label }: { label: string }) {
  const input = useTemplateRef<HTMLInputElement>();
  onMounted(() => {
    if (input.value) input.value.value = "Ada";
  });
  return <input ref={input} name="name" aria-label={label} />;
}
