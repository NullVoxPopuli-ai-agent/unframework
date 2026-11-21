<script setup lang="ts">
import NameField from "./NameField.vue";
import { computed, useTemplateRef } from "vue";

const nameComponent = useTemplateRef<{ $el: HTMLInputElement }>("nameComponent");
const name = computed(() => nameComponent.value?.$el ?? null);
</script>

<template>
  <form aria-label="Profile">
    <NameField ref="nameComponent" label="Name" />
    <button type="button" @click="name?.focus()">Edit name</button>
  </form>
</template>
