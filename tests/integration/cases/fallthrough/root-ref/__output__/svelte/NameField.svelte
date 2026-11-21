<svelte:options runes={true} preserveWhitespace={false} />

<script lang="ts">
  import type { ClassValue, HTMLInputAttributes } from "svelte/elements";

  type Props = Omit<HTMLInputAttributes, "label" | "children" | "class" | "style" | "ref"> & {
    label: string;
    class?: ClassValue;
    style?: string;
    ref?: HTMLElementTagNameMap["input"] | null;
  };

  let {
    label,
    class: className,
    style,
    ref = $bindable(null),
    onfocus,
    ...attributes
  }: Props = $props();

  let input: HTMLInputElement | null = null;

  function fill() {
    if (input && !input.value) input.value = "Ada";
  }
</script>

<input
  bind:this={() => input, (element) => {
    input = element;
    ref = element;
  }}
  name="name"
  aria-label={label}
  onfocus={(event) => {
    fill();
    onfocus?.(event);
  }}
  class={className}
  {style}
  {...attributes}
/>
