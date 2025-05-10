<template>
  <button
    :class="[
      'px-4 py-2 rounded font-semibold transition-all',
      colorClass,
      { 'opacity-50 cursor-not-allowed': disabled }
    ]"
    :disabled="disabled"
    @click="$emit('click', $event)"
  >
    <slot />
  </button>
</template>

<script setup lang="ts">
defineProps({
  color: {
    type: String,
    default: 'primary',
  },
  disabled: {
    type: Boolean,
    default: false,
  },
})

const colorClass = computed(() => {
  switch (props.color) {
    case 'primary':
      return 'bg-primary text-white hover:bg-primary-dark';
    case 'secondary':
      return 'bg-secondary text-white hover:bg-secondary-dark';
    case 'accent':
      return 'bg-accent text-white hover:bg-accent-dark';
    default:
      return 'bg-gray-500 text-white hover:bg-gray-700';
  }
});
</script>
