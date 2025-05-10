<template>
  <Layout>
    <div class="flex justify-between items-center mb-6">
      <h1 class="font-heading text-2xl">Incidents & Complaints</h1>
      <router-link :to="{ name: 'IncidentCreateForm' }">
        <Button color="primary">Report Incident</Button>
      </router-link>
    </div>
    <div class="grid gap-6 grid-cols-1 sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-4">
      <router-link
        v-for="incident in incidents"
        :key="incident.id"
        :to="{ name: 'IncidentDetail', params: { id: incident.id } }"
        class="card shadow-lg border border-gray-100 hover:shadow-xl transition-all bg-white flex flex-col cursor-pointer no-underline"
        style="color: inherit;"
      >
        <div class="flex items-center justify-between mb-2">
          <span :class="[
            'rounded-full px-3 py-1 text-xs font-semibold',
            incident.type === 'compliment' ? 'bg-success text-white' : (incident.type === 'complaint' ? 'bg-error text-white' : 'bg-info text-white')
          ]">
            {{ incident.type.charAt(0).toUpperCase() + incident.type.slice(1) }}
          </span>
          <span :class="[
            'rounded-full px-3 py-1 text-xs font-semibold',
            item.status === 'open' ? 'bg-success text-white' : 'bg-secondary text-white'
          ]">
            {{ item.status.charAt(0).toUpperCase() + item.status.slice(1) }}
          </span>
        </div>
        <div class="mb-2">
          <div class="text-xs text-gray-500 mb-1">Description:</div>
          <div class="text-base text-primary font-medium">{{ item.description }}</div>
        </div>
        <div class="mb-2">
          <div class="text-xs text-gray-500 mb-1">Assigned Users:</div>
          <div class="flex flex-wrap gap-1">
            <span v-for="userId in item.assigned_users" :key="userId" class="inline-block bg-primary/10 text-primary px-2 py-1 rounded-full text-xs font-medium">
              {{ getUserName(userId) }}
            </span>
          </div>
        </div>
        <div class="mt-auto flex gap-2">
          <Button color="secondary" size="sm" @click="editIncident(item)">Edit</Button>
        </div>
      </div>
    </div>
    <Modal :show="showCreate" @close="showCreate = false">
      <h2 class="font-heading text-xl mb-2">Create Incident/Complaint</h2>
      <form @submit.prevent="createIncident">
        <select v-model="newIncident.type" class="mb-2 p-2 border rounded w-full">
  <option value="incident">Incident</option>
  <option value="complaint">Complaint</option>
  <option value="compliment">Compliment</option>
</select>
        <Input v-model="newIncident.description" placeholder="Description" class="mb-2" />
        <select v-model="newIncident.status" class="mb-2 p-2 border rounded w-full">
          <option value="open">Open</option>
          <option value="closed">Closed</option>
        </select>
        <select v-model="newIncident.assigned_users" multiple class="mb-2 p-2 border rounded w-full">
          <option v-for="user in users" :key="user.id" :value="user.id">{{ user.name }}</option>
        </select>
        <select v-model="newIncident.action_plan_ids" multiple class="mb-2 p-2 border rounded w-full">
          <option v-for="plan in actionPlans" :key="plan.id" :value="plan.id">{{ plan.name }}</option>
        </select>
        <select v-model="newIncident.audit_ids" multiple class="mb-2 p-2 border rounded w-full">
          <option v-for="audit in audits" :key="audit.id" :value="audit.id">{{ audit.title }}</option>
        </select>
        <select v-model="newIncident.safeguarding_case_ids" multiple class="mb-4 p-2 border rounded w-full">
          <option v-for="caseItem in safeguardingCases" :key="caseItem.id" :value="caseItem.id">{{ caseItem.type }} - {{ caseItem.description }}</option>
        </select>
        <Button color="primary" class="w-full">Create</Button>
      </form>
    </Modal>
    <Modal :show="!!editTarget" @close="editTarget = null">
      <h2 class="font-heading text-xl mb-2">Edit Incident/Complaint</h2>
      <form @submit.prevent="updateIncident">
        <select v-model="editTarget.type" class="mb-2 p-2 border rounded w-full">
  <option value="incident">Incident</option>
  <option value="complaint">Complaint</option>
  <option value="compliment">Compliment</option>
</select>
        <Input v-model="editTarget.description" placeholder="Description" class="mb-2" />
        <select v-model="editTarget.status" class="mb-2 p-2 border rounded w-full">
          <option value="open">Open</option>
          <option value="closed">Closed</option>
        </select>
        <select v-model="editTarget.assigned_users" multiple class="mb-2 p-2 border rounded w-full">
          <option v-for="user in users" :key="user.id" :value="user.id">{{ user.name }}</option>
        </select>
        <select v-model="editTarget.action_plan_ids" multiple class="mb-2 p-2 border rounded w-full">
          <option v-for="plan in actionPlans" :key="plan.id" :value="plan.id">{{ plan.name }}</option>
        </select>
        <select v-model="editTarget.audit_ids" multiple class="mb-2 p-2 border rounded w-full">
          <option v-for="audit in audits" :key="audit.id" :value="audit.id">{{ audit.title }}</option>
        </select>
        <select v-model="editTarget.safeguarding_case_ids" multiple class="mb-4 p-2 border rounded w-full">
          <option v-for="caseItem in safeguardingCases" :key="caseItem.id" :value="caseItem.id">{{ caseItem.type }} - {{ caseItem.description }}</option>
        </select>
        <Button color="primary" class="w-full">Update</Button>
      </form>
    </Modal>
  </Layout>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import Layout from '../components/Layout.vue'
import Table from '../components/Table.vue'
import Button from '../components/Button.vue'
import Modal from '../components/Modal.vue'
import Input from '../components/Input.vue'
import { supabase } from '../supabase'
import { sendEmailNotification } from '../services/notificationService'

const incidents = ref<any[]>([])
const users = ref<any[]>([])
const actionPlans = ref<any[]>([])
const audits = ref<any[]>([])
const safeguardingCases = ref<any[]>([])
const showCreate = ref(false)
const newIncident = ref({
  type: '',
  description: '',
  status: 'open',
  assigned_users: [],
  action_plan_ids: [],
  audit_ids: [],
  safeguarding_case_ids: []
})
const editTarget = ref<any | null>(null)

function getUserName(id: string) {
  const user = users.value.find(u => u.id === id)
  return user ? user.name : id
}

async function fetchIncidents() {
  const { data, error } = await supabase.from('incidents').select('*')
  if (!error) incidents.value = data || []
}
async function fetchUsers() {
  const { data, error } = await supabase.from('users').select('id, name')
  if (!error) users.value = data || []
}
let incidentSubscription: any = null
onMounted(() => {
  fetchIncidents();
  fetchUsers();
  fetchActionPlans();
  fetchAudits();
  fetchSafeguardingCases();
  // Real-time updates
  incidentSubscription = supabase
    .channel('incidents')
    .on('postgres_changes', { event: '*', schema: 'public', table: 'incidents' }, payload => {
      fetchIncidents()
    })
    .subscribe()
})
onUnmounted(() => {
  if (incidentSubscription) supabase.removeChannel(incidentSubscription)
})

async function createIncident() {
  await supabase.from('incidents').insert([
    {
      type: newIncident.value.type,
      description: newIncident.value.description,
      status: newIncident.value.status,
      assigned_users: newIncident.value.assigned_users,
      action_plan_ids: newIncident.value.action_plan_ids,
      audit_ids: newIncident.value.audit_ids,
      safeguarding_case_ids: newIncident.value.safeguarding_case_ids
    },
  ])
  showCreate.value = false
  fetchIncidents()
  // Notify assigned users
  const assigned = users.value.filter(u => newIncident.value.assigned_users.includes(u.id))
  for (const user of assigned) {
    // Email notification
    if (user.email) {
      await sendEmailNotification({
        to: user.email,
        subject: `New Incident Assigned: ${newIncident.value.type}`,
        html: `<p>You have been assigned to the incident: <b>${newIncident.value.type}</b>.<br>Description: ${newIncident.value.description}<br>Status: ${newIncident.value.status}</p>`
      })
    }
    // In-app notification
    await supabase.from('notifications').insert({
      user_id: user.id,
      title: `New Incident Assigned`,
      message: `You have been assigned to the incident: ${newIncident.value.type}. Status: ${newIncident.value.status}`
    })
  }
}

function editIncident(item: any) {
  editTarget.value = { ...item }
}

async function updateIncident() {
  if (!editTarget.value) return
  await supabase.from('incidents').update({
    type: editTarget.value.type,
    description: editTarget.value.description,
    status: editTarget.value.status,
    assigned_users: editTarget.value.assigned_users,
    action_plan_ids: editTarget.value.action_plan_ids,
    audit_ids: editTarget.value.audit_ids,
    safeguarding_case_ids: editTarget.value.safeguarding_case_ids
  }).eq('id', editTarget.value.id)
  // Notify assigned users
  const assigned = users.value.filter(u => editTarget.value.assigned_users.includes(u.id))
  for (const user of assigned) {
    if (user.email) {
      await sendEmailNotification({
        to: user.email,
        subject: `Incident Updated: ${editTarget.value.type}`,
        html: `<p>Your assigned incident has been updated: <b>${editTarget.value.type}</b>.<br>Description: ${editTarget.value.description}<br>Status: ${editTarget.value.status}</p>`
      })
    }
  }
  editTarget.value = null
  fetchIncidents()
}
async function fetchActionPlans() {
  const { data, error } = await supabase.from('action_plans').select('id, name')
  if (!error) actionPlans.value = data || []
}
async function fetchAudits() {
  const { data, error } = await supabase.from('audits').select('id, title')
  if (!error) audits.value = data || []
}
async function fetchSafeguardingCases() {
  const { data, error } = await supabase.from('safeguarding').select('id, type, description')
  if (!error) safeguardingCases.value = data || []
}
</script>
