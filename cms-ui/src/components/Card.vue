<template>
  <div class="card">
    <slot />
  </div>
</template>

<script setup lang="ts">
defineProps({
  type: {
    type: String,
    default: 'default',
    validator: (value) => ['default', 'primary', 'accent', 'success', 'error', 'info'].includes(value)
  }
})
</script>

<style scoped>
.card {
  background-color: white;
  border-radius: 0.5rem;
  padding: 1.25rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.card.primary {
  border-left: 4px solid var(--color-primary);
}

.card.accent {
  border-left: 4px solid var(--color-accent);
}

.card.success {
  border-left: 4px solid var(--color-success);
}

.card.error {
  border-left: 4px solid var(--color-error);
}

.card.info {
  border-left: 4px solid var(--color-info);
}
</style>
