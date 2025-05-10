<template>
  <table class="data-table">
    <thead>
      <tr>
        <slot name="header" />
      </tr>
    </thead>
    <tbody>
      <slot />
    </tbody>
  </table>
</template>

<script setup lang="ts">
// Use slots for flexible table structure
</script>

<style scoped>
.data-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.875rem;
  background-color: white;
  border-radius: 0.5rem;
  overflow: hidden;
}

.data-table th {
  text-align: left;
  padding: 0.75rem 1rem;
  background-color: var(--color-background, #F9FAFB);
  font-weight: 500;
  color: var(--color-text, #1F2937);
  border-bottom: 1px solid #E5E7EB;
}

.data-table td {
  padding: 0.75rem 1rem;
  border-bottom: 1px solid #E5E7EB;
  color: var(--color-text, #1F2937);
}

.data-table tbody tr:hover {
  background-color: rgba(0, 0, 0, 0.02);
}

.data-table tbody tr:last-child td {
  border-bottom: none;
}
</style>
