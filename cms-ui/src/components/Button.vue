<template>
  <button
    :class="['button', `button-${color}`, { 'disabled': disabled }]"
    :disabled="disabled"
    @click="$emit('click', $event)"
  >
    <slot />
  </button>
</template>

<script setup lang="ts">
const props = defineProps({
  color: {
    type: String,
    default: 'primary',
    validator: (value) => ['primary', 'accent', 'success', 'error', 'info'].includes(value)
  },
  disabled: {
    type: Boolean,
    default: false,
  },
})

defineEmits(['click'])
</script>

<style scoped>
.button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0.5rem 1rem;
  min-width: 44px;
  min-height: 44px;
  border-radius: 0.375rem;
  font-weight: 600;
  font-size: 1rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  transition: all 0.2s ease;
  cursor: pointer;
  border: none;
}

.button:focus {
  outline: none;
  box-shadow: 0 0 0 3px rgba(0, 112, 243, 0.3);
}

.button-primary {
  background-color: var(--color-primary);
  color: white;
}

.button-primary:hover {
  background-color: rgba(0, 112, 243, 0.9);
}

.button-primary:active {
  background-color: rgba(0, 112, 243, 0.8);
}

.button-accent {
  background-color: var(--color-accent);
  color: white;
}

.button-accent:hover {
  background-color: rgba(255, 122, 89, 0.9);
}

.button-accent:active {
  background-color: rgba(255, 122, 89, 0.8);
}

.button-success {
  background-color: var(--color-success);
  color: white;
}

.button-success:hover {
  background-color: rgba(16, 185, 129, 0.9);
}

.button-success:active {
  background-color: rgba(16, 185, 129, 0.8);
}

.button-error {
  background-color: var(--color-error);
  color: white;
}

.button-error:hover {
  background-color: rgba(239, 68, 68, 0.9);
}

.button-error:active {
  background-color: rgba(239, 68, 68, 0.8);
}

.button-info {
  background-color: var(--color-info);
  color: white;
}

.button-info:hover {
  background-color: rgba(59, 130, 246, 0.9);
}

.button-info:active {
  background-color: rgba(59, 130, 246, 0.8);
}

.button.disabled {
  opacity: 0.5;
  cursor: not-allowed;
  pointer-events: none;
}
</style>
