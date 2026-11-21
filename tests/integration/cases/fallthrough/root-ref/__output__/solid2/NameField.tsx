import type { ComponentProps, JSX } from "@solidjs/web";
import { omit, onCleanup } from "solid-js";

export default function NameField(
  props: { label: string } & Omit<
    ComponentProps<"input">,
    "label" | "class" | "style" | "onFocus"
  > & {
      class?: string;
      style?: JSX.CSSProperties;
      onFocus?: Extract<ComponentProps<"input">["onFocus"], (event: never) => void>;
    },
) {
  const others = omit(props, "label", "onFocus");

  let input: HTMLInputElement | null = null;

  function fill() {
    if (input && !input.value) input.value = "Ada";
  }

  return (
    <input
      ref={clearedRef(
        (element) => {
          input = element;
        },
        () => {
          input = null;
        },
      )}
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

/** A `ref` that calls `callback` with its element, and `clear` once the element is removed. */
function clearedRef<T>(callback: (element: T) => void, clear: () => void): (element: T) => void {
  onCleanup(clear);
  return callback;
}
