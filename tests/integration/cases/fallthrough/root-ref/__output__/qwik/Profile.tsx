import NameField from "./NameField";
import {
  type CSSProperties,
  type ClassList,
  type PropsOf,
  component$,
  useSignal,
} from "@qwik.dev/core";

export default component$<
  Omit<PropsOf<"form">, "class" | "style"> & { class?: ClassList; style?: CSSProperties }
>(({ class: className, style, ...attributes }) => {
  const name = useSignal<HTMLInputElement>();

  return (
    <form aria-label="Profile" class={className} style={style} {...attributes}>
      <NameField ref={name} label="Name" />
      <button type="button" onClick$={() => name.value?.focus()}>
        Edit name
      </button>
    </form>
  );
});
