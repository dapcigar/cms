<template>
  <div v-if="show" class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-40">
    <div class="bg-white rounded-lg shadow-lg w-full max-w-md p-6 relative">
      <button @click="$emit('close')" class="absolute top-2 right-2 text-gray-400 hover:text-gray-800">&times;</button>
      <slot />
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps({
  show: Boolean,
})
</script>
