import { type ComponentPropsWithRef, type Ref, type RefCallback, useMemo, useRef } from "react";

export type NameFieldAttributes = Omit<ComponentPropsWithRef<"input">, "label" | "children">;

export default function NameField({
  label,
  className,
  style,
  onFocus,
  ref,
  ...attributes
}: { label: string } & NameFieldAttributes) {
  const input = useRef<HTMLInputElement>(null);

  function fill() {
    if (input.current && !input.current.value) input.current.value = "Ada";
  }

  const rootRef = useMemo(() => mergeRefs(input, ref), [input, ref]);

  return (
    <input
      ref={rootRef}
      name="name"
      aria-label={label}
      onFocus={(event) => {
        fill();
        onFocus?.(event);
      }}
      className={className}
      style={style}
      {...attributes}
    />
  );
}

/** Joins an element's refs into one ref callback, whose cleanup clears each. */
function mergeRefs<E extends Element>(...refs: (Ref<E> | undefined)[]): RefCallback<E> {
  return (element) => {
    const cleanups = refs.map((ref) => {
      if (typeof ref === "function") {
        const cleanup = ref(element);
        return typeof cleanup === "function" ? cleanup : () => ref(null);
      }
      if (ref) ref.current = element;
      return () => {
        if (ref) ref.current = null;
      };
    });
    return () => {
      for (const cleanup of cleanups) cleanup();
    };
  };
}
