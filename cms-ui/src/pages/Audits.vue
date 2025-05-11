<template>
  <Layout>
    <div class="flex justify-between items-center mb-6">
      <h1 class="font-heading text-2xl">Audits</h1>
      <Button color="primary" @click="showCreate = true">New Audit</Button>
    </div>

    <div class="bg-white rounded-lg shadow overflow-hidden">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Title</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Assigned Users</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Created</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <tr v-for="audit in audits" :key="audit.id" class="hover:bg-gray-50">
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm font-medium text-primary">{{ audit.title }}</div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span :class="[
                'px-2 py-1 text-xs font-semibold rounded-full',
                audit.status === 'open' ? 'bg-success/10 text-success' : 'bg-secondary/10 text-secondary'
              ]">
                {{ audit.status.charAt(0).toUpperCase() + audit.status.slice(1) }}
              </span>
            </td>
            <td class="px-6 py-4">
              <div class="flex flex-wrap gap-1">
                <span 
                  v-for="userId in audit.assigned_users" 
                  :key="userId" 
                  class="inline-flex items-center gap-1 bg-primary/10 text-primary px-2 py-1 rounded-full text-xs font-medium"
                >
                  <i class="material-icons text-sm">person</i>
                  {{ getUserName(userId) }}
                </span>
                <span v-if="!audit.assigned_users?.length" class="text-gray-400 text-sm">No users assigned</span>
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
              {{ new Date(audit.created_at).toLocaleDateString() }}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
              <Button color="secondary" size="sm" @click="editAudit(audit)">Edit</Button>
            </td>
          </tr>
          <tr v-if="audits.length === 0">
            <td colspan="5" class="px-6 py-4 text-center text-sm text-gray-500">
              No audits found. Click "New Audit" to create one.
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Pagination Controls -->
    <div class="flex items-center justify-between mt-4 px-4 py-3 bg-white border-t border-gray-200">
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
  </Layout>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import Layout from '../components/Layout.vue'
import Button from '../components/Button.vue'
import Modal from '../components/Modal.vue'
import Input from '../components/Input.vue'
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
