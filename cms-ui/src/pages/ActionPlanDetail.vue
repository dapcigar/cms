<template>
  <Layout>
    <div class="mb-6">
      <h1 class="font-heading text-2xl mb-1">Action Plan Details</h1>
      <div class="text-secondary mb-2">ID: {{ plan.id }}</div>
    </div>
    <Tabs :tabs="tabDefs" v-model="activeTab" />
    <div v-if="activeTab === 0" class="mt-4">
      <h2 class="font-heading text-lg mb-2">Summary</h2>
      <div class="mb-2"><b>Name:</b> {{ plan.name }}</div>
      <div class="mb-2"><b>Status:</b> {{ plan.status }}</div>
      <div class="mb-2"><b>Due Date:</b> {{ plan.due_date }}</div>
      <div class="mb-2"><b>Assigned Users:</b>
        <span v-for="userId in plan.assigned_users" :key="userId" class="inline-block bg-secondary/10 text-secondary px-2 py-1 rounded-full text-xs font-medium mr-1">{{ getUserName(userId) }}</span>
      </div>
    </div>
    <div v-else-if="activeTab === 1" class="mt-4">
      <h2 class="font-heading text-lg mb-2">Related Incidents</h2>
      <ul class="list-disc pl-6">
        <li v-for="incidentId in plan.incident_ids || []" :key="incidentId">Incident: {{ getIncidentDesc(incidentId) }}</li>
      </ul>
    </div>
    <div v-else-if="activeTab === 2" class="mt-4">
      <h2 class="font-heading text-lg mb-2">Update History</h2>
      <ul class="list-disc pl-6">
        <li v-for="log in plan.logs || []" :key="log.id">{{ log.date }} - {{ log.message }}</li>
      </ul>
    </div>
    <div v-else-if="activeTab === 3" class="mt-4">
      <h2 class="font-heading text-lg mb-2">Logs</h2>
      <pre class="bg-gray-100 rounded p-3 text-xs overflow-x-auto">{{ JSON.stringify(plan, null, 2) }}</pre>
    </div>
  </Layout>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import Layout from '../components/Layout.vue'
import Tabs from '../components/Tabs.vue'
import { useRoute } from 'vue-router'
import { supabase } from '../supabase'
const route = useRoute()
const plan = ref<any>(null)
const users = ref<any[]>([])
const incidents = ref<any[]>([])
const loading = ref(true)

async function fetchDetail() {
  loading.value = true
  const { data: pl } = await supabase.from('action_plans').select('*').eq('id', route.params.id).single()
  plan.value = pl
  const { data: userData } = await supabase.from('users').select('id, name')
  users.value = userData || []
  const { data: incData } = await supabase.from('incidents').select('id, description')
  incidents.value = incData || []
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
function getIncidentDesc(id: string) {
  const inc = incidents.value.find(i => i.id === id)
  return inc ? inc.description : id
}
</script>
