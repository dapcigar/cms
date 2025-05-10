<template>
  <input
    :type="type"
    :placeholder="placeholder"
    :value="modelValue"
    @input="$emit('update:modelValue', $event.target.value)"
    class="px-3 py-2 border rounded w-full focus:outline-none focus:ring-2 focus:ring-primary"
  />
</template>

<script setup lang="ts">
defineProps({
  modelValue: String,
  type: {
    type: String,
    default: 'text',
  },
  placeholder: {
    type: String,
    default: '',
  },
})
</script>
