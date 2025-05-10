<template>
  <Layout>
    <div class="flex items-center gap-4 mb-6">
      <router-link :to="{ name: 'Audits' }" class="text-gray-500 hover:text-primary">
        <i class="material-icons">arrow_back</i>
      </router-link>
      <div>
        <h1 class="font-heading text-2xl">{{ audit?.title || 'Loading...' }}</h1>
        <div class="text-gray-500 text-sm">#{{ $route.params.id }}</div>
      </div>
      <Button v-if="audit" color="primary" class="ml-auto" @click="showEditModal = true">Edit Audit</Button>
    </div>

    <div v-if="loading" class="flex items-center justify-center py-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
    </div>

    <template v-else-if="audit">
      <div class="grid gap-6 grid-cols-1 lg:grid-cols-3">
        <Card class="lg:col-span-2 p-6">
          <div class="flex items-center justify-between mb-4">
            <h2 class="font-heading text-lg">Details</h2>
            <span :class="[
              'rounded-full px-3 py-1 text-xs font-semibold',
              audit.status === 'open' ? 'bg-success/10 text-success' : 'bg-secondary/10 text-secondary'
            ]">
              {{ audit.status.charAt(0).toUpperCase() + audit.status.slice(1) }}
            </span>
          </div>
          
          <div class="space-y-4">
            <div>
              <label class="text-sm text-gray-500">Description</label>
              <p class="mt-1">{{ audit.description || 'No description provided' }}</p>
            </div>

            <div>
              <label class="text-sm text-gray-500">Assigned Users</label>
              <div class="mt-2 flex flex-wrap gap-2">
                <span 
                  v-for="userId in audit.assigned_users" 
                  :key="userId" 
                  class="inline-flex items-center gap-1 bg-primary/10 text-primary px-3 py-1 rounded-full text-sm font-medium"
                >
                  <i class="material-icons text-sm">person</i>
                  {{ getUserName(userId) }}
                </span>
                <span v-if="!audit.assigned_users?.length" class="text-gray-400 text-sm">No users assigned</span>
              </div>
            </div>
          </div>
        </Card>

        <Card class="p-6">
          <h2 class="font-heading text-lg mb-4">Activity</h2>
          <div class="space-y-4">
            <div v-for="log in auditLogs" :key="log.id" class="flex gap-3">
              <div class="flex-none">
                <div class="w-8 h-8 rounded-full bg-primary/10 text-primary flex items-center justify-center">
                  <i class="material-icons text-sm">{{ log.icon }}</i>
                </div>
              </div>
              <div>
                <div class="text-sm font-medium">{{ log.message }}</div>
                <div class="text-xs text-gray-500">{{ formatDate(log.created_at) }}</div>
              </div>
            </div>
            <div v-if="!auditLogs.length" class="text-gray-500 text-sm">No activity recorded yet</div>
          </div>
        </Card>
      </div>

      <Card class="mt-6 p-6">
        <h2 class="font-heading text-lg mb-4">Related Incidents</h2>
        <div class="space-y-2">
          <div v-for="incident in incidents" :key="incident.id" class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
            <div>
              <div class="font-medium">{{ incident.title }}</div>
              <div class="text-sm text-gray-500">{{ incident.description }}</div>
            </div>
            <Button color="primary" size="sm" @click="viewIncident(incident.id)">View</Button>
          </div>
          <div v-if="!incidents.length" class="text-gray-500 text-sm text-center py-4">
            No related incidents found
          </div>
        </div>
      </Card>
    </template>

    <Modal :show="showEditModal" @close="showEditModal = false">
      <h2 class="font-heading text-xl mb-4">Edit Audit</h2>
      <form v-if="audit" @submit.prevent="updateAudit" class="space-y-4">
        <div>
          <label class="block text-sm font-medium mb-1">Title</label>
          <Input v-model="editForm.title" placeholder="Enter audit title" />
        </div>

        <div>
          <label class="block text-sm font-medium mb-1">Description</label>
          <textarea
            v-model="editForm.description"
            rows="4"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
            placeholder="Enter audit description"
          ></textarea>
        </div>

        <div>
          <label class="block text-sm font-medium mb-1">Status</label>
          <select 
            v-model="editForm.status"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
          >
            <option value="open">Open</option>
            <option value="closed">Closed</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium mb-1">Assigned Users</label>
          <select
            v-model="editForm.assigned_users"
            multiple
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
          >
            <option v-for="user in users" :key="user.id" :value="user.id">
              {{ user.name }}
            </option>
          </select>
          <p class="mt-1 text-xs text-gray-500">Hold Ctrl/Cmd to select multiple users</p>
        </div>

        <div class="pt-4">
          <Button type="submit" color="primary" class="w-full">Update Audit</Button>
        </div>
      </form>
    </Modal>
  </Layout>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import Layout from '../components/Layout.vue'
import Card from '../components/Card.vue'
import Button from '../components/Button.vue'
import Modal from '../components/Modal.vue'
import Input from '../components/Input.vue'
import { supabase } from '../supabase'

const route = useRoute()
const router = useRouter()

const audit = ref<any>(null)
const users = ref<any[]>([])
const incidents = ref<any[]>([])
const auditLogs = ref<any[]>([])
const loading = ref(true)
const showEditModal = ref(false)

const editForm = ref({
  title: '',
  description: '',
  status: 'open',
  assigned_users: []
})

async function fetchAudit() {
  const { data, error } = await supabase
    .from('audits')
    .select('*')
    .eq('id', route.params.id)
    .single()

  if (error) {
    console.error('Error fetching audit:', error)
    return
  }

  audit.value = data
  editForm.value = {
    title: data.title,
    description: data.description || '',
    status: data.status,
    assigned_users: data.assigned_users || []
  }
}

async function fetchUsers() {
  const { data, error } = await supabase.from('users').select('id, name')
  if (!error) users.value = data || []
}

async function fetchIncidents() {
  // Assuming we have a junction table audit_incidents
  const { data, error } = await supabase
    .from('incidents')
    .select('*')
    .eq('audit_id', route.params.id)

  if (!error) incidents.value = data || []
}

async function fetchAuditLogs() {
  const { data, error } = await supabase
    .from('audit_logs')
    .select('*')
    .eq('audit_id', route.params.id)
    .order('created_at', { ascending: false })

  if (!error) auditLogs.value = data || []
}

async function updateAudit() {
  const { error } = await supabase
    .from('audits')
    .update({
      title: editForm.value.title,
      description: editForm.value.description,
      status: editForm.value.status,
      assigned_users: editForm.value.assigned_users
    })
    .eq('id', audit.value.id)

  if (!error) {
    // Log the update
    await supabase.from('audit_logs').insert({
      audit_id: audit.value.id,
      message: 'Audit details updated',
      icon: 'edit'
    })

    // Notify assigned users
    for (const userId of editForm.value.assigned_users) {
      if (!audit.value.assigned_users.includes(userId)) {
        await supabase.from('notifications').insert({
          user_id: userId,
          title: 'Audit Assignment',
          message: `You have been assigned to the audit: ${editForm.value.title}`
        })
      }
    }

    showEditModal.value = false
    fetchAudit()
    fetchAuditLogs()
  }
}

function getUserName(id: string) {
  const user = users.value.find(u => u.id === id)
  return user ? user.name : 'Unknown User'
}

function viewIncident(id: string) {
  router.push({ name: 'IncidentDetail', params: { id } })
}

function formatDate(date: string) {
  return new Date(date).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

onMounted(async () => {
  await Promise.all([
    fetchAudit(),
    fetchUsers(),
    fetchIncidents(),
    fetchAuditLogs()
  ])
  loading.value = false
})
</script>
