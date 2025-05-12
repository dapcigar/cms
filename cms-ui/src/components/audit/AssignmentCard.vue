<template>
  <div class="assignment-card border border-[#E5E7EB] rounded-lg overflow-hidden">
    <div class="p-4">
      <div class="flex justify-between items-start">
        <div>
          <h3 class="font-medium text-lg text-[#1F2937]">Audit Assignment</h3>
          <div class="text-sm text-[#6B7280] mt-1">
            Assigned to: {{ assignment.assignedToUser?.email || assignment.assignedToUser?.full_name || 'Unknown User' }}
          </div>
        </div>
        
        <div class="flex flex-col items-end">
          <span 
            class="px-2 py-1 text-xs rounded-full mb-2 font-medium"
            :style="badgeStyle"
            aria-label="Assignment Status"
          >
            {{ formattedStatus }}
          </span>
          <span class="text-sm text-[#6B7280]">
            Due: {{ formatDate(assignment.due_date) }}
          </span>
        </div>
      </div>
      
      <div class="mt-4 flex justify-between items-center">
        <div class="text-sm text-[#6B7280]">
          Assigned by {{ assignment.assignedByUser?.full_name || 'Admin' }} on {{ formatDate(assignment.created_at) }}
        </div>
        
        <button 
          v-if="assignment.status !== 'completed'"
          @click="$emit('complete', assignment.id)"
          class="text-sm bg-[#10B981] hover:bg-[#059669] text-white px-3 py-1 rounded-md transition-colors"
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

const badgeStyle = computed(() => {
  switch (assignment.status) {
    case 'pending':
      return 'background-color: #EFF6FF; color: #3B82F6;'; // Info blue
    case 'in_progress':
      return 'background-color: #F0F9FF; color: #0070F3;'; // Primary blue
    case 'completed':
      return 'background-color: #ECFDF5; color: #10B981;'; // Success green
    case 'overdue':
      return 'background-color: #FEF2F2; color: #EF4444;'; // Error red
    default:
      return 'background-color: #F9FAFB; color: #1F2937;'; // Background/Text colors
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
