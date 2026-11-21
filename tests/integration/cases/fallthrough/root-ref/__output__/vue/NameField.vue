<script setup lang="ts">
import { useTemplateRef } from "vue";

const { label } = defineProps<{ label: string }>();

const input = useTemplateRef<HTMLInputElement>("input");

function fill() {
  if (input.value && !input.value.value) input.value.value = "Ada";
}
</script>

<template>
  <input ref="input" name="name" :aria-label="label" @focus="fill" />
</template>
