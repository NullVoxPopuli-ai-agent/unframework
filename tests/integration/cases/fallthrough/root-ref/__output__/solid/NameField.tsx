import { type ComponentProps, type JSX, onCleanup, splitProps } from "solid-js";

export default function NameField(
  props: { label: string } & Omit<ComponentProps<"input">, "label" | "style" | "onFocus"> & {
      style?: JSX.CSSProperties;
      onFocus?: Extract<ComponentProps<"input">["onFocus"], (event: never) => void>;
    },
) {
  const [, others] = splitProps(props, ["label", "onFocus"]);

  let input: HTMLInputElement | null = null;

  function fill() {
    if (input && !input.value) input.value = "Ada";
  }

  return (
    <input
      ref={(element) => {
        input = element;
        onCleanup(() => {
          input = null;
        });
      }}
      name="name"
      aria-label={props.label}
      onFocus={(event) => {
        fill();
        props.onFocus?.(event);
      }}
      {...others}
    />
  );
}
