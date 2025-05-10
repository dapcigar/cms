<template>
  <table class="min-w-full bg-white border border-gray-200 rounded-lg overflow-hidden">
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
