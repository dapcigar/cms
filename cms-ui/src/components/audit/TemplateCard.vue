<template>
  <div class="template-card border border-slate-200 rounded-lg overflow-hidden hover:shadow-md transition-shadow">
    <div class="p-4">
      <div class="flex justify-between items-start">
        <h3 class="font-medium text-lg text-slate-800">{{ template.title }}</h3>
        <span 
          class="px-2 py-1 text-xs rounded-full"
          :class="{
            'bg-blue-100 text-blue-800': template.frequency === 'daily',
            'bg-purple-100 text-purple-800': template.frequency === 'weekly',
            'bg-green-100 text-green-800': template.frequency === 'monthly'
          }"
        >
          {{ template.frequency }}
        </span>
      </div>
      
      <div class="mt-2 text-sm text-slate-600">
        Created: {{ formatDate(template.created_at) }}
      </div>
      
      <div class="mt-4 flex space-x-2">
        <button 
          @click="$emit('edit', template)"
          class="text-sm text-blue-600 hover:text-blue-800"
        >
          Edit
        </button>
        <button 
          @click="$emit('delete', template.id)"
          class="text-sm text-red-600 hover:text-red-800"
        >
          Delete
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps({
  template: {
    type: Object,
    required: true
  }
})

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString()
}
</script>

<style scoped>
.template-card {
  @apply bg-white;
}
</style>
