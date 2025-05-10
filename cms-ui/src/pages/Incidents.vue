<template>
  <Layout>
    <div class="flex justify-between items-center mb-6">
      <h1 class="font-heading text-2xl">Incidents & Complaints</h1>
      <Button color="primary" @click="showCreate = true">New Incident/Complaint</Button>
    </div>
    <Table>
      <template #header>
        <th class="text-left p-2">Type</th>
        <th class="text-left p-2">Description</th>
        <th class="text-left p-2">Status</th>
        <th class="text-left p-2">Assigned Users</th>
        <th class="text-left p-2">Actions</th>
      </template>
      <tr v-for="item in incidents" :key="item.id">
        <td class="p-2">{{ item.type }}</td>
        <td class="p-2">{{ item.description }}</td>
        <td class="p-2">{{ item.status }}</td>
        <td class="p-2">
          <span v-for="user in item.assigned_users" :key="user" class="inline-block bg-primary-light text-primary-dark px-2 py-1 rounded mr-1 text-xs">{{ user }}</span>
        </td>
        <td class="p-2">
          <Button color="secondary" size="sm" @click="editIncident(item)">Edit</Button>
        </td>
      </tr>
    </Table>
    <Modal :show="showCreate" @close="showCreate = false">
      <h2 class="font-heading text-xl mb-2">Create Incident/Complaint</h2>
      <form @submit.prevent="createIncident">
        <Input v-model="newIncident.type" placeholder="Type" class="mb-2" />
        <Input v-model="newIncident.description" placeholder="Description" class="mb-2" />
        <select v-model="newIncident.status" class="mb-2 p-2 border rounded w-full">
          <option value="open">Open</option>
          <option value="closed">Closed</option>
        </select>
        <select v-model="newIncident.assigned_users" multiple class="mb-4 p-2 border rounded w-full">
          <option v-for="user in users" :key="user.id" :value="user.id">{{ user.name }}</option>
        </select>
        <Button color="primary" class="w-full">Create</Button>
      </form>
    </Modal>
    <Modal :show="!!editTarget" @close="editTarget = null">
      <h2 class="font-heading text-xl mb-2">Edit Incident/Complaint</h2>
      <form @submit.prevent="updateIncident">
        <Input v-model="editTarget.type" placeholder="Type" class="mb-2" />
        <Input v-model="editTarget.description" placeholder="Description" class="mb-2" />
        <select v-model="editTarget.status" class="mb-2 p-2 border rounded w-full">
          <option value="open">Open</option>
          <option value="closed">Closed</option>
        </select>
        <select v-model="editTarget.assigned_users" multiple class="mb-4 p-2 border rounded w-full">
          <option v-for="user in users" :key="user.id" :value="user.id">{{ user.name }}</option>
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
const showCreate = ref(false)
const newIncident = ref({ type: '', description: '', status: 'open', assigned_users: [] })
const editTarget = ref<any | null>(null)

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
</script>
