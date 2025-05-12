<template>
  <div class="audit-dashboard">
    <h1 class="text-2xl font-bold text-slate-800 mb-6">Audit Analytics</h1>
    
    <!-- Summary Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
      <DashboardCard 
        title="Total Audits" 
        :value="stats.total_audits"
        icon="📋"
        color="bg-blue-100 text-blue-800"
      />
      <DashboardCard 
        title="Completed" 
        :value="stats.completed_audits"
        icon="✅"
        color="bg-green-100 text-green-800"
      />
      <DashboardCard 
        title="In Progress" 
        :value="stats.in_progress_audits"
        icon="🔄"
        color="bg-yellow-100 text-yellow-800"
      />
      <DashboardCard 
        title="Overdue" 
        :value="stats.overdue_audits"
        icon="⚠️"
        color="bg-red-100 text-red-800"
      />
    </div>
    
    <!-- Charts Section -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
      <!-- Completion Rate Chart -->
      <div class="bg-white p-4 rounded-lg shadow-sm">
        <h2 class="text-lg font-semibold text-slate-800 mb-4">Completion Rate</h2>
        <CompletionChart :data="completionData" />
      </div>
      
      <!-- Score Distribution Chart -->
      <div class="bg-white p-4 rounded-lg shadow-sm">
        <h2 class="text-lg font-semibold text-slate-800 mb-4">Score Distribution</h2>
        <ScoreChart :data="scoreData" />
      </div>
    </div>
    
    <!-- Recent Audits Table -->
    <div class="bg-white p-4 rounded-lg shadow-sm">
      <h2 class="text-lg font-semibold text-slate-800 mb-4">Recent Audits</h2>
      <AuditTable :audits="recentAudits" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '../supabase'
import DashboardCard from '../components/audit/DashboardCard.vue'
import CompletionChart from '../components/audit/CompletionChart.vue'
import ScoreChart from '../components/audit/ScoreChart.vue'
import AuditTable from '../components/audit/AuditTable.vue'

const stats = ref({
  total_audits: 0,
  completed_audits: 0,
  in_progress_audits: 0,
  overdue_audits: 0
})

const completionData = ref<any[]>([])
const scoreData = ref<any[]>([])
const recentAudits = ref<any[]>([])

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
  
  // Get completion data by template
  const { data: completion } = await supabase
    .from('audit_completion_rates')
    .select('*')
    
  completionData.value = completion || []
  
  // Get score distribution
  const { data: scores } = await supabase
    .from('audit_score_distribution')
    .select('*')
    
  scoreData.value = scores || []
  
  // Get recent audits
  const { data: audits } = await supabase
    .from('audit_assignments')
    .select(`
      *,
      assigned_to:profiles!audit_assignments_assigned_to_fkey(*),
      template:audit_templates!audit_assignments_template_id_fkey(*)
    `)
    .order('created_at', { ascending: false })
    .limit(5)
    
  recentAudits.value = audits || []
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
