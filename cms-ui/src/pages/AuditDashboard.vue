<template>
  <div class="audit-dashboard">
    <div class="dashboard-header">
      <h1>Audit Analytics</h1>
    </div>
    <div class="flex justify-between items-center mb-8">
      <h1 class="text-2xl font-semibold text-gray-800">Audit Analytics</h1>
    </div>

    <div class="dashboard-stats">
      <div class="stat-card stat-primary">
        <span class="stat-label">Total Audits</span>
        <span class="stat-value">{{ stats.total_audits }}</span>
      </div>
      <div class="stat-card stat-success">
        <span class="stat-label">Completed Audits</span>
        <span class="stat-value">{{ stats.completed_audits }}</span>
      </div>
      <div class="stat-card stat-accent">
        <span class="stat-label">Overdue Audits</span>
        <span class="stat-value">{{ stats.overdue_audits }}</span>
      </div>
    </div>

    <div class="bg-white rounded-lg shadow-md p-6">
      <h2 class="text-xl font-medium text-gray-700 mb-4">Charts & Reports</h2>
      <p class="text-gray-600 text-center py-8">
        Analytics charts will appear here.
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '../supabase'

const stats = ref({
  total_audits: 0,
  completed_audits: 0,
  in_progress_audits: 0,
  overdue_audits: 0
})

// Fetch dashboard data
async function fetchData() {
  // Get counts
  const { count: total } = await supabase
    .from('audit_assignments')
    .select('*', { count: 'exact' })
    
  const { count: completed } = await supabase
    .from('audit_assignments')
    .select('*', { count: 'exact' })
    .eq('status', 'completed')
    
  const { count: inProgress } = await supabase
    .from('audit_assignments')
    .select('*', { count: 'exact' })
    .eq('status', 'in_progress')
    
  const { count: overdue } = await supabase
    .from('audit_assignments')
    .select('*', { count: 'exact' })
    .lt('due_date', new Date().toISOString())
    .neq('status', 'completed')
    
  stats.value = {
    total_audits: total || 0,
    completed_audits: completed || 0,
    in_progress_audits: inProgress || 0,
    overdue_audits: overdue || 0
  }
}

// Initialize component
onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.audit-dashboard {
  @apply p-6;
}
</style>
