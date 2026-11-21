<script setup lang="ts">
import Chip from "./Chip.vue";
import { shallowRef } from "vue";

const log = shallowRef<string[]>([]);

function record(line: string) {
  log.value = [...log.value, line];
}
</script>

<template>
  <section aria-label="Picker">
    <Chip
      label="Ada"
      @click="() => record('click')"
      @pick="(label) => record(`pick ${label}`)"
      @focus="() => record('focus')"
      @keydown="(event) => record(`keydown ${event.key}`)"
    />
    <ol aria-label="Log">
      <li v-for="(entry, index) in log" :key="index">{{ entry }}</li>
    </ol>
  </section>
</template>
