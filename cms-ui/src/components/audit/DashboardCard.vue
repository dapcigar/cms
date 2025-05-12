<template>
  <div class="dashboard-card" :class="color">
    <div class="flex items-center">
      <div class="text-2xl mr-3">{{ icon }}</div>
      <div>
        <div class="text-sm font-medium">{{ title }}</div>
        <div class="text-2xl font-bold">{{ value }}</div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps({
  title: {
    type: String,
    required: true
  },
  value: {
    type: [Number, String],
    required: true
  },
  icon: {
    type: String,
    default: '📊'
  },
  color: {
    type: String,
    default: 'bg-slate-100 text-slate-800'
  }
})
</script>

<style scoped>
.dashboard-card {
  @apply p-4 rounded-lg shadow-sm;
}
</style>
