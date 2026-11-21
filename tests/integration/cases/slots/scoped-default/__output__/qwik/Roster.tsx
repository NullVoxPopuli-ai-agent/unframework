import Names from "./Names";
import { type CSSProperties, type ClassList, type PropsOf, component$ } from "@qwik.dev/core";

export default component$<
  { names: string[] } & Omit<PropsOf<"ul">, "names" | "class" | "style"> & {
      class?: ClassList;
      style?: CSSProperties;
    }
>(({ names, class: className, style, ...attributes }) => {
  return (
    <>
      <Names
        names={names}
        default$={({ item }) => <b>{item}!</b>}
        class={className}
        style={style}
        {...attributes}
      />
    </>
  );
});
