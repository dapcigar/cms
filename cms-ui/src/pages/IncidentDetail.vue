<template>
  <Layout>
    <div class="mb-6">
      <h1 class="font-heading text-2xl mb-1">Incident Details</h1>
      <div class="text-secondary mb-2">ID: {{ incident.id }}</div>
    </div>
    <Tabs :tabs="tabDefs" v-model="activeTab" />
    <div v-if="activeTab === 0" class="mt-4">
      <h2 class="font-heading text-lg mb-2">Summary</h2>
      <div class="mb-2"><b>Type:</b> {{ incident.type }}</div>
      <div class="mb-2"><b>Description:</b> {{ incident.description }}</div>
      <div class="mb-2"><b>Status:</b> {{ incident.status }}</div>
      <div class="mb-2"><b>Assigned Users:</b>
        <span v-for="userId in incident.assigned_users" :key="userId" class="inline-block bg-primary/10 text-primary px-2 py-1 rounded-full text-xs font-medium mr-1">{{ getUserName(userId) }}</span>
      </div>
    </div>
    <div v-else-if="activeTab === 1" class="mt-4">
      <h2 class="font-heading text-lg mb-2">Related Actions</h2>
      <ul class="list-disc pl-6">
        <li v-for="planId in incident.action_plan_ids" :key="planId">Action Plan: {{ getPlanName(planId) }}</li>
        <li v-for="auditId in incident.audit_ids" :key="auditId">Audit: {{ getAuditTitle(auditId) }}</li>
        <li v-for="caseId in incident.safeguarding_case_ids" :key="caseId">Safeguarding: {{ getCaseDesc(caseId) }}</li>
      </ul>
    </div>
    <div v-else-if="activeTab === 2" class="mt-4">
      <h2 class="font-heading text-lg mb-2">Update History</h2>
      <ul class="list-disc pl-6">
        <li v-for="log in incident.logs || []" :key="log.id">{{ log.date }} - {{ log.message }}</li>
      </ul>
    </div>
    <div v-else-if="activeTab === 3" class="mt-4">
      <h2 class="font-heading text-lg mb-2">Logs</h2>
      <pre class="bg-gray-100 rounded p-3 text-xs overflow-x-auto">{{ JSON.stringify(incident, null, 2) }}</pre>
    </div>
  </Layout>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import Layout from '../components/Layout.vue'
import Tabs from '../components/Tabs.vue'
import { useRoute } from 'vue-router'
import { supabase } from '../supabase'
const route = useRoute()
const incident = ref<any>(null)
const users = ref<any[]>([])
const plans = ref<any[]>([])
const audits = ref<any[]>([])
const cases = ref<any[]>([])
const loading = ref(true)

async function fetchDetail() {
  loading.value = true
  const { data: inc } = await supabase.from('incidents').select('*').eq('id', route.params.id).single()
  incident.value = inc
  const { data: userData } = await supabase.from('users').select('id, name')
  users.value = userData || []
  const { data: planData } = await supabase.from('action_plans').select('id, name')
  plans.value = planData || []
  const { data: auditData } = await supabase.from('audits').select('id, title')
  audits.value = auditData || []
  const { data: caseData } = await supabase.from('safeguarding').select('id, description')
  cases.value = caseData || []
  loading.value = false
}
onMounted(fetchDetail)

const tabDefs = [
  { label: 'Summary', icon: 'info' },
  { label: 'Related', icon: 'link' },
  { label: 'History', icon: 'history' },
  { label: 'Logs', icon: 'list_alt' }
]
const activeTab = ref(0)
function getUserName(id: string) {
  const user = users.value.find(u => u.id === id)
  return user ? user.name : id
}
function getPlanName(id: string) {
  const plan = plans.value.find(p => p.id === id)
  return plan ? plan.name : id
}
function getAuditTitle(id: string) {
  const audit = audits.value.find(a => a.id === id)
  return audit ? audit.title : id
}
function getCaseDesc(id: string) {
  const sg = cases.value.find(c => c.id === id)
  return sg ? sg.description : id
}
</script>
