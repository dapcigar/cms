<template>
  <Layout>
    <div class="audits-page bg-gray-50 min-h-screen p-6">
      <div class="audits-header">
        <h1 class="text-2xl font-semibold text-gray-800">Audits</h1>
        <button 
          v-if="activeTab === 'assignments'" 
          @click="showCreate = true"
          class="primary-btn"
        >
          <span class="material-icons">add</span>
          New Audit
        </button>
      </div>

      <!-- Tabs Navigation -->
      <div class="audits-tabs">
        <button
          v-for="tab in tabs"
          :key="tab.id"
          @click="activeTab = tab.id"
          class="tab-btn"
          :class="{ active: activeTab === tab.id }"
        >
          {{ tab.label }}
        </button>
      </div>

      <!-- Tab Content -->
      <div class="audits-content">
        <!-- Assignments Tab -->
        <div v-show="activeTab === 'assignments'" class="p-6">
          <AuditAssignments />
        </div>
        
        <!-- Templates Tab -->
        <div v-show="activeTab === 'templates'" class="p-6">
          <AuditTemplates />
        </div>
        
        <!-- Dashboard Tab -->
        <div v-show="activeTab === 'dashboard'" class="p-6">
          <AuditDashboard />
        </div>
      </div>

      <!-- Pagination Controls -->
      <div v-if="activeTab === 'assignments'" class="flex items-center justify-between mt-4 px-4 py-3 bg-white border-t border-gray-200">
        <div class="text-sm text-gray-500">
          Showing <span class="font-medium">{{ (currentPage - 1) * itemsPerPage + 1 }}</span> to 
          <span class="font-medium">{{ Math.min(currentPage * itemsPerPage, totalItems) }}</span> of 
          <span class="font-medium">{{ totalItems }}</span> audits
        </div>
        
        <div class="flex space-x-2">
          <Button 
            color="secondary" 
            size="sm"
            :disabled="currentPage === 1"
            @click="currentPage--; fetchAudits()"
          >
            Previous
          </Button>
          
          <Button 
            color="secondary" 
            size="sm"
            :disabled="currentPage * itemsPerPage >= totalItems"
            @click="currentPage++; fetchAudits()"
          >
            Next
          </Button>
        </div>
      </div>

      <Modal :show="showCreate" @close="showCreate = false">
        <h2 class="font-heading text-xl mb-2">Create Audit</h2>
        <form @submit.prevent="createAudit">
          <Input v-model="newAudit.title" placeholder="Title" class="mb-2" />
          <select v-model="newAudit.status" class="mb-2 p-2 border rounded w-full">
            <option value="open">Open</option>
            <option value="closed">Closed</option>
          </select>
          <select v-model="newAudit.assigned_users" multiple class="mb-4 p-2 border rounded w-full">
            <option v-for="user in users" :key="user.id" :value="user.id">{{ user.name }}</option>
          </select>
          <Button color="primary" class="w-full">Create</Button>
        </form>
      </Modal>
      <Modal :show="!!editTarget" @close="editTarget = null">
        <h2 class="font-heading text-xl mb-2">Edit Audit</h2>
        <form @submit.prevent="updateAudit">
          <Input v-model="editTarget.title" placeholder="Title" class="mb-2" />
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
    </div>
  </Layout>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import Layout from '../components/Layout.vue'
import Button from '../components/Button.vue'
import Modal from '../components/Modal.vue'
import Input from '../components/Input.vue'
import AuditAssignments from './AuditAssignments.vue'
import AuditTemplates from './AuditTemplates.vue'
import AuditDashboard from './AuditDashboard.vue'
import { supabase } from '../supabase'

const audits = ref<any[]>([])
const users = ref<any[]>([])
const showCreate = ref(false)
const newAudit = ref({ title: '', status: 'open', assigned_users: [] })
const editTarget = ref<any | null>(null)

// Pagination
const currentPage = ref(1)
const itemsPerPage = 10
const totalItems = ref(0)

const activeTab = ref('assignments')
const tabs = [
  { id: 'assignments', label: 'Assignments' },
  { id: 'templates', label: 'Templates' },
  { id: 'dashboard', label: 'Analytics' }
]

function getUserName(id: string) {
  const user = users.value.find(u => u.id === id)
  return user ? user.name || user.email || user.id : id
}

async function fetchAudits() {
  const from = (currentPage.value - 1) * itemsPerPage
  const to = from + itemsPerPage - 1
  
  // First get total count
  const { count } = await supabase
    .from('audits')
    .select('*', { count: 'exact', head: true })
  
  totalItems.value = count || 0
  
  // Then get paginated data
  const { data, error } = await supabase
    .from('audits')
    .select('id, title, status, description, assigned_users, created_at')
    .order('created_at', { ascending: false })
    .range(from, to)
  
  if (error) {
    console.error('Error fetching audits:', error)
    return
  }
  
  audits.value = data || []
}

async function fetchUsers() {
  const { data, error } = await supabase
    .from('users')
    .select('id, name, email')
    .order('name')
  
  if (error) {
    console.error('Error fetching users:', error)
    return
  }
  
  users.value = data || []
}

let auditSubscription: any = null
onMounted(() => {
  fetchAudits();
  fetchUsers();
  // Real-time updates
  auditSubscription = supabase
    .channel('audits')
    .on('postgres_changes', { event: '*', schema: 'public', table: 'audits' }, payload => {
      fetchAudits()
    })
    .subscribe()
})
onUnmounted(() => {
  if (auditSubscription) supabase.removeChannel(auditSubscription)
})

async function createAudit() {
  const { data, error } = await supabase
    .from('audits')
    .insert([
      {
        title: newAudit.value.title,
        status: newAudit.value.status,
        assigned_users: newAudit.value.assigned_users,
        created_at: new Date().toISOString()
      },
    ])
    .select()
    .single()

  if (error) {
    console.error('Error creating audit:', error)
    return
  }

  // Notify assigned users
  const assigned = users.value.filter(u => newAudit.value.assigned_users.includes(u.id))
  for (const user of assigned) {
    await supabase.from('notifications').insert({
      user_id: user.id,
      title: 'New Audit Assigned',
      message: `You have been assigned to the audit: ${newAudit.value.title}`,
      created_at: new Date().toISOString()
    })
  }

  showCreate.value = false
  newAudit.value = { title: '', status: 'open', assigned_users: [] }
  fetchAudits()
}

function editAudit(audit: any) {
  editTarget.value = { ...audit }
}

async function updateAudit() {
  if (!editTarget.value) return
  await supabase.from('audits').update({
    title: editTarget.value.title,
    status: editTarget.value.status,
    assigned_users: editTarget.value.assigned_users,
  }).eq('id', editTarget.value.id)
  // Notify assigned users
  const assigned = users.value.filter(u => editTarget.value.assigned_users.includes(u.id))
  for (const user of assigned) {
    // Email notification
    if (user.email) {
      await sendEmailNotification({
        to: user.email,
        subject: `Audit Updated: ${editTarget.value.title}`,
        html: `<p>Your assigned audit has been updated: <b>${editTarget.value.title}</b>.<br>Status: ${editTarget.value.status}</p>`
      })
    }
    // In-app notification
    await supabase.from('notifications').insert({
      user_id: user.id,
      title: `Audit Updated`,
      message: `Your assigned audit has been updated: ${editTarget.value.title}. Status: ${editTarget.value.status}`
    })
  }
  editTarget.value = null
  fetchAudits()
}
</script>

<style scoped>
/* Custom styles for smooth transitions */
.audits-page {
  transition: background-color 0.3s ease;
}
</style>
