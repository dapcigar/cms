<template>
  <div class="audit-table">
    <table class="min-w-full divide-y divide-slate-200">
      <thead class="bg-slate-50">
        <tr>
          <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Template</th>
          <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Assigned To</th>
          <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Status</th>
          <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Due Date</th>
          <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Score</th>
        </tr>
      </thead>
      <tbody class="bg-white divide-y divide-slate-200">
        <tr v-for="audit in audits" :key="audit.id">
          <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-800">
            {{ audit.template.title }}
          </td>
          <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-800">
            {{ audit.assigned_to.email }}
          </td>
          <td class="px-6 py-4 whitespace-nowrap">
            <span 
              class="px-2 py-1 text-xs rounded-full"
              :class="{
                'bg-blue-100 text-blue-800': audit.status === 'pending',
                'bg-yellow-100 text-yellow-800': audit.status === 'in_progress',
                'bg-green-100 text-green-800': audit.status === 'completed',
                'bg-red-100 text-red-800': audit.status === 'overdue'
              }"
            >
              {{ formatStatus(audit.status) }}
            </span>
          </td>
          <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-800">
            {{ formatDate(audit.due_date) }}
          </td>
          <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-800">
            {{ audit.score || '-' }}
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup lang="ts">
defineProps({
  audits: {
    type: Array,
    required: true
  }
})

function formatStatus(status: string) {
  return {
    'pending': 'Pending',
    'in_progress': 'In Progress',
    'completed': 'Completed',
    'overdue': 'Overdue'
  }[status]
}

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString()
}
</script>

<style scoped>
.audit-table {
  @apply overflow-x-auto;
}
</style>
