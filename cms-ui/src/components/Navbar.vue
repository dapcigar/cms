<template>
  <nav class="flex items-center justify-between px-6 py-3 bg-primary text-white shadow">
    <div class="font-heading text-xl font-bold tracking-tight">Care Management System</div>
    <div class="flex items-center gap-4">
      <slot name="actions" />
      <button class="rounded-full bg-white bg-opacity-20 px-3 py-1 hover:bg-opacity-40 transition">Profile</button>
    </div>
  </nav>
</template>

<script setup lang="ts">
// Extend as needed for navigation actions
</script>
