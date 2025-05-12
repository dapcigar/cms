<template>
  <transition name="toast">
    <div 
      v-if="show" 
      :class="[
        'fixed top-4 right-4 px-4 py-2 rounded-lg shadow-lg flex items-center gap-2 z-50 transition-all',
        type === 'success' ? 'bg-[#D1FAE5] text-[#10B981]' : 'bg-[#FEE2E2] text-[#EF4444]'
      ]"
    >
      <span class="material-icons text-sm">
        {{ type === 'success' ? 'check_circle' : 'error' }}
      </span>
      <span class="font-medium">{{ message }}</span>
    </div>
  </transition>
</template>

<script setup lang="ts">
defineProps({
  show: {
    type: Boolean,
    required: true
  },
  message: {
    type: String,
    required: true
  },
  type: {
    type: String,
    default: 'success',
    validator: (value: string) => ['success', 'error'].includes(value)
  }
})
</script>

<style scoped>
.toast-enter-active,
.toast-leave-active {
  transition: all 0.3s ease;
}

.toast-enter-from,
.toast-leave-to {
  opacity: 0;
  transform: translateY(-1rem);
}
</style>
