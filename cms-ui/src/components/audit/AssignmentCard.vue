<template>
  <div class="assignment-card border border-slate-200 rounded-lg overflow-hidden">
    <div class="p-4">
      <div class="flex justify-between items-start">
        <div>
          <h3 class="font-medium text-lg text-slate-800">{{ assignment.template.title }}</h3>
          <div class="text-sm text-slate-600 mt-1">
            Assigned to: {{ assignment.assigned_to.email }}
          </div>
        </div>
        
        <div class="flex flex-col items-end">
          <span 
            class="px-2 py-1 text-xs rounded-full mb-2"
            :class="statusClasses"
          >
            {{ formattedStatus }}
          </span>
          <span class="text-sm text-slate-600">
            Due: {{ formatDate(assignment.due_date) }}
          </span>
        </div>
      </div>
      
      <div class="mt-4 flex justify-between items-center">
        <div class="text-sm text-slate-500">
          Assigned by {{ assignment.assigned_by.email }} on {{ formatDate(assignment.created_at) }}
        </div>
        
        <button 
          v-if="assignment.status !== 'completed'"
          @click="$emit('complete', assignment.id)"
          class="text-sm bg-green-600 hover:bg-green-700 text-white px-3 py-1 rounded-md"
        >
          Mark Complete
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps({
  assignment: {
    type: Object,
    required: true
  }
})

defineEmits(['complete'])

const statusClasses = computed(() => {
  return {
    'bg-blue-100 text-blue-800': assignment.status === 'pending',
    'bg-yellow-100 text-yellow-800': assignment.status === 'in_progress',
    'bg-green-100 text-green-800': assignment.status === 'completed',
    'bg-red-100 text-red-800': assignment.status === 'overdue'
  }
})

const formattedStatus = computed(() => {
  return {
    'pending': 'Pending',
    'in_progress': 'In Progress',
    'completed': 'Completed',
    'overdue': 'Overdue'
  }[assignment.status]
})

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString()
}
</script>

<style scoped>
.assignment-card {
  @apply bg-white hover:shadow-md transition-shadow;
}
</style>
