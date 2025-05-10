<template>
  <Layout>
    <div class="mb-6">
      <h1 class="font-heading text-2xl mb-1">Audit Details</h1>
      <div class="text-secondary mb-2">ID: {{ audit.id }}</div>
    </div>
    <Tabs :tabs="tabDefs" v-model="activeTab" />
    <div v-if="activeTab === 0" class="mt-4">
      <h2 class="font-heading text-lg mb-2">Summary</h2>
      <div class="mb-2"><b>Title:</b> {{ audit.title }}</div>
      <div class="mb-2"><b>Status:</b> {{ audit.status }}</div>
      <div class="mb-2"><b>Assigned Users:</b>
        <span v-for="userId in audit.assigned_users" :key="userId" class="inline-block bg-primary/10 text-primary px-2 py-1 rounded-full text-xs font-medium mr-1">{{ getUserName(userId) }}</span>
      </div>
    </div>
    <div v-else-if="activeTab === 1" class="mt-4">
      <h2 class="font-heading text-lg mb-2">Related Incidents</h2>
      <ul class="list-disc pl-6">
        <li v-for="incidentId in audit.incident_ids || []" :key="incidentId">Incident: {{ getIncidentDesc(incidentId) }}</li>
      </ul>
    </div>
    <div v-else-if="activeTab === 2" class="mt-4">
      <h2 class="font-heading text-lg mb-2">Update History</h2>
      <ul class="list-disc pl-6">
        <li v-for="log in audit.logs || []" :key="log.id">{{ log.date }} - {{ log.message }}</li>
      </ul>
    </div>
    <div v-else-if="activeTab === 3" class="mt-4">
      <h2 class="font-heading text-lg mb-2">Logs</h2>
      <pre class="bg-gray-100 rounded p-3 text-xs overflow-x-auto">{{ JSON.stringify(audit, null, 2) }}</pre>
    </div>
  </Layout>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import Layout from '../components/Layout.vue'
import Tabs from '../components/Tabs.vue'
// Placeholder: Replace with real fetch logic
const audit = ref({
  id: 'AUD-001',
  title: 'Q1 Audit',
  status: 'open',
  assigned_users: ['u1', 'u2'],
  incident_ids: ['inc1'],
  logs: [
    { id: 1, date: '2025-05-10', message: 'Created' },
    { id: 2, date: '2025-05-11', message: 'Assigned to user' }
  ]
})
const users = ref([{ id: 'u1', name: 'Alice' }, { id: 'u2', name: 'Bob' }])
const incidents = ref([{ id: 'inc1', description: 'Medication error' }])
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
