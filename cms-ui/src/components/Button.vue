<template>
  <button
    :class="[
      'px-4 py-2 min-w-[44px] min-h-[44px] rounded-xl font-semibold text-base sm:text-lg shadow-md transition-all focus:outline-none focus:ring-2 focus:ring-accent',
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
import { computed } from 'vue'
const props = defineProps({
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
      return 'bg-primary text-white hover:bg-primary-dark active:bg-primary-dark';
    case 'secondary':
      return 'bg-secondary text-white hover:bg-secondary-dark active:bg-secondary-dark';
    case 'accent':
      return 'bg-accent text-white hover:bg-accent-dark active:bg-accent-dark';
    case 'success':
      return 'bg-success text-white hover:bg-success/90 active:bg-success/80';
    case 'error':
      return 'bg-error text-white hover:bg-error/90 active:bg-error/80';
    case 'info':
      return 'bg-info text-white hover:bg-info/90 active:bg-info/80';
    default:
      return 'bg-secondary text-white hover:bg-secondary-dark active:bg-secondary-dark';
  }
});
</script>
