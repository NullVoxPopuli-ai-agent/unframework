import {
  $,
  type CSSProperties,
  type ClassList,
  type PropsOf,
  type Signal,
  component$,
  useSignal,
} from "@qwik.dev/core";

export default component$<
  { label: string } & Omit<PropsOf<"input">, "label" | "class" | "style" | "ref"> & {
      class?: ClassList;
      style?: CSSProperties;
      ref?: Signal<Element | undefined>;
    }
>(({ label, class: className, style, onFocus$, ref, ...attributes }) => {
  const input = useSignal<HTMLInputElement>();

  const fill = $(() => {
    if (input.value && !input.value.value) input.value.value = "Ada";
  });

  return (
    <input
      ref={(element) => {
        input.value = element;
        if (ref) ref.value = element;
      }}
      name="name"
      aria-label={label}
      onFocus$={[fill, onFocus$]}
      class={className}
      style={style}
      {...attributes}
    />
  );
});
