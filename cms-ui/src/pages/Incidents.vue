<template>
  <Layout>
    <div class="flex justify-between items-center mb-6">
      <h1 class="font-heading text-2xl">Incidents & Complaints</h1>
      <Button color="primary" @click="showCreate = true">Report Incident</Button>
    </div>

    <!-- Filter Controls -->
    <div class="bg-white p-4 rounded-lg shadow border border-gray-100 mb-6">
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Status</label>
          <select 
            v-model="filters.status" 
            class="w-full p-2 border rounded-md focus:ring-[#0070F3] focus:border-[#0070F3]"
            @change="fetchIncidents"
          >
            <option value="">All Statuses</option>
            <option value="open">Open</option>
            <option value="closed">Closed</option>
          </select>
        </div>
        
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Type</label>
          <select 
            v-model="filters.type" 
            class="w-full p-2 border rounded-md focus:ring-[#0070F3] focus:border-[#0070F3]"
            @change="fetchIncidents"
          >
            <option value="">All Types</option>
            <option value="incident">Incident</option>
            <option value="complaint">Complaint</option>
            <option value="compliment">Compliment</option>
          </select>
        </div>
        
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Date Range</label>
          <div class="flex gap-2">
            <input 
              type="date" 
              v-model="filters.dateFrom" 
              class="w-full p-2 border rounded-md focus:ring-[#0070F3] focus:border-[#0070F3]"
              @change="fetchIncidents"
            >
            <input 
              type="date" 
              v-model="filters.dateTo" 
              class="w-full p-2 border rounded-md focus:ring-[#0070F3] focus:border-[#0070F3]"
              @change="fetchIncidents"
            >
          </div>
        </div>
        
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Assigned To</label>
          <select 
            v-model="filters.assignedUser" 
            class="w-full p-2 border rounded-md focus:ring-[#0070F3] focus:border-[#0070F3]"
            @change="fetchIncidents"
          >
            <option value="">All Users</option>
            <option v-for="user in users" :key="user.id" :value="user.id">
              {{ user.name || user.email }}
            </option>
          </select>
        </div>
      </div>
      
      <div class="mt-4 flex justify-end">
        <Button 
          color="secondary" 
          size="sm"
          @click="resetFilters"
        >
          Reset Filters
        </Button>
      </div>
    </div>

    <div v-if="incidentsError" class="mb-4 p-4 rounded-lg" style="background:#FF7A59;color:white;">
      <strong>Error:</strong> {{ incidentsError }}
    </div>

    <div v-else-if="incidents.length" class="overflow-x-auto">
      <table class="min-w-full bg-white rounded-lg shadow border border-gray-100">
        <thead>
          <tr class="bg-[#0070F3] text-white">
            <th 
              class="px-4 py-3 text-left cursor-pointer hover:bg-[#0070F3]/90"
              @click="toggleSort('type')"
            >
              <div class="flex items-center">
                Type
                <span v-if="sortColumn === 'type'" class="ml-1">
                  {{ sortDirection === 'asc' ? '↑' : '↓' }}
                </span>
              </div>
            </th>
            <th 
              class="px-4 py-3 text-left cursor-pointer hover:bg-[#0070F3]/90"
              @click="toggleSort('description')"
            >
              <div class="flex items-center">
                Description
                <span v-if="sortColumn === 'description'" class="ml-1">
                  {{ sortDirection === 'asc' ? '↑' : '↓' }}
                </span>
              </div>
            </th>
            <th 
              class="px-4 py-3 text-left cursor-pointer hover:bg-[#0070F3]/90"
              @click="toggleSort('status')"
            >
              <div class="flex items-center">
                Status
                <span v-if="sortColumn === 'status'" class="ml-1">
                  {{ sortDirection === 'asc' ? '↑' : '↓' }}
                </span>
              </div>
            </th>
            <th class="px-4 py-3 text-left">Assigned Users</th>
            <th 
              class="px-4 py-3 text-left cursor-pointer hover:bg-[#0070F3]/90"
              @click="toggleSort('created_at')"
            >
              <div class="flex items-center">
                Date
                <span v-if="sortColumn === 'created_at'" class="ml-1">
                  {{ sortDirection === 'asc' ? '↑' : '↓' }}
                </span>
              </div>
            </th>
            <th class="px-4 py-3 text-left">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="incident in incidents" :key="incident.id" class="hover:bg-[#F9FAFB] transition-colors">
            <td class="px-4 py-3">
              <span :class="[
                'inline-block rounded px-3 py-1 text-xs font-semibold',
                incident.type === 'compliment' ? 'bg-[#10B981] text-white' : 
                (incident.type === 'complaint' ? 'bg-[#EF4444] text-white' : 'bg-[#3B82F6] text-white')
              ]">
                {{ incident.type.charAt(0).toUpperCase() + incident.type.slice(1) }}
              </span>
            </td>
            <td class="px-4 py-3 text-[#1F2937] max-w-xs truncate">{{ incident.description }}</td>
            <td class="px-4 py-3">
              <span :class="[
                'inline-block rounded px-3 py-1 text-xs font-semibold',
                incident.status === 'open' ? 'bg-[#10B981]/10 text-[#10B981]' : 'bg-[#FF7A59]/10 text-[#FF7A59]'
              ]">
                {{ incident.status.charAt(0).toUpperCase() + incident.status.slice(1) }}
              </span>
            </td>
            <td class="px-4 py-3">
              <div class="flex flex-wrap gap-1">
                <span 
                  v-for="userId in incident.assigned_users" 
                  :key="userId" 
                  class="inline-flex items-center gap-1 bg-[#0070F3]/10 text-[#0070F3] px-2 py-1 rounded-full text-xs font-medium"
                >
                  <i class="material-icons text-sm">person</i>
                  {{ getUserName(userId) }}
                </span>
              </div>
            </td>
            <td class="px-4 py-3 text-sm text-[#1F2937]">
              {{ new Date(incident.created_at).toLocaleDateString() }}
            </td>
            <td class="px-4 py-3">
              <Button color="secondary" size="sm" @click="editIncident(incident)">Edit</Button>
            </td>
          </tr>
        </tbody>
      </table>

      <!-- Pagination -->
      <div class="flex items-center justify-between mt-4 px-4 py-3 bg-white border-t border-gray-200">
        <div class="text-sm text-gray-500">
          Showing <span class="font-medium">{{ (currentPage - 1) * itemsPerPage + 1 }}</span> to 
          <span class="font-medium">{{ Math.min(currentPage * itemsPerPage, totalItems) }}</span> of 
          <span class="font-medium">{{ totalItems }}</span> incidents
        </div>
        
        <div class="flex space-x-2">
          <Button 
            color="secondary" 
            size="sm"
            :disabled="currentPage === 1"
            @click="currentPage--; fetchIncidents()"
          >
            Previous
          </Button>
          
          <Button 
            color="secondary" 
            size="sm"
            :disabled="currentPage * itemsPerPage >= totalItems"
            @click="currentPage++; fetchIncidents()"
          >
            Next
          </Button>
        </div>
      </div>
    </div>

    <div v-else class="text-center py-12">
      <div class="text-gray-500 mb-4">No incidents found</div>
      <Button color="primary" @click="showCreate = true">Report First Incident</Button>
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
import { ref, onMounted, onUnmounted } from 'vue'
import Layout from '../components/Layout.vue'
import Button from '../components/Button.vue'
import Modal from '../components/Modal.vue'
import Input from '../components/Input.vue'
import { supabase } from '../supabase'
import { sendEmailNotification } from '../services/notificationService'
import { generateUUID } from '../utils/uuid'

const incidents = ref<any[]>([])
const users = ref<any[]>([])
const actionPlans = ref<any[]>([])
const audits = ref<any[]>([])
const safeguardingCases = ref<any[]>([])
const incidentsError = ref<string | null>(null)
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

// Sorting and Filtering
const sortColumn = ref<string>('created_at')
const sortDirection = ref<'asc' | 'desc'>('desc')

const filters = ref({
  status: '',
  type: '',
  dateFrom: '',
  dateTo: '',
  assignedUser: ''
})

function toggleSort(column: string) {
  if (sortColumn.value === column) {
    sortDirection.value = sortDirection.value === 'asc' ? 'desc' : 'asc'
  } else {
    sortColumn.value = column
    sortDirection.value = 'asc'
  }
  fetchIncidents()
}

function resetFilters() {
  filters.value = {
    status: '',
    type: '',
    dateFrom: '',
    dateTo: '',
    assignedUser: ''
  }
  fetchIncidents()
}

// Pagination
const currentPage = ref(1)
const itemsPerPage = 10
const totalItems = ref(0)

function getUserName(id: string) {
  const user = users.value.find(u => u.id === id)
  return user ? user.email : id
}

async function fetchIncidents() {
  try {
    // Base query
    let query = supabase
      .from('incidents')
      .select('*', { count: 'exact' })
      
    // Apply filters
    if (filters.value.status) {
      query = query.eq('status', filters.value.status)
    }
    if (filters.value.type) {
      query = query.eq('type', filters.value.type)
    }
    if (filters.value.dateFrom) {
      query = query.gte('created_at', `${filters.value.dateFrom}T00:00:00`)
    }
    if (filters.value.dateTo) {
      query = query.lte('created_at', `${filters.value.dateTo}T23:59:59`)
    }
    if (filters.value.assignedUser) {
      query = query.contains('assigned_users', [filters.value.assignedUser])
    }
    
    // Apply sorting
    query = query.order(sortColumn.value, { 
      ascending: sortDirection.value === 'asc' 
    })
    
    // Apply pagination
    const from = (currentPage.value - 1) * itemsPerPage
    const to = from + itemsPerPage - 1
    query = query.range(from, to)
    
    const { data, count, error } = await query
    
    if (error) {
      incidentsError.value = 'Failed to fetch incidents. Please try again later.'
      throw error
    }
    
    incidents.value = data || []
    totalItems.value = count || 0
  } catch (error) {
    console.error('Error fetching incidents:', error)
    incidents.value = []
    totalItems.value = 0
  }
}

async function fetchUsers() {
  const { data, error } = await supabase
    .from('profiles')
    .select('id, email')
    .order('email')
  if (error) {
    console.error('Error fetching users:', error)
    return
  }
  users.value = data || []
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
  try {
    const incidentData = {
      ...newIncident.value,
      id: generateUUID(),
      created_at: new Date().toISOString(),
    }
    const { error } = await supabase.from('incidents').insert([incidentData])
    if (error) throw error
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
  } catch (error) {
    console.error('Error creating incident:', error)
  }
}

function editIncident(item: any) {
  editTarget.value = { ...item }
}

async function updateIncident() {
  if (!editTarget.value) return
  try {
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
      // In-app notification
      await supabase.from('notifications').insert({
        user_id: user.id,
        title: `Incident Updated`,
        message: `Incident ${editTarget.value.type} has been updated. Status: ${editTarget.value.status}`
      })
    }
    
    editTarget.value = null
    await fetchIncidents()
  } catch (error) {
    console.error('Error updating incident:', error)
  }
}
async function fetchActionPlans() {
  const { data, error } = await supabase.from('action_plans').select('id, name')
  if (error) {
    console.error('Error fetching action plans:', error)
    return
  }
  actionPlans.value = data || []
}
async function fetchAudits() {
  const { data, error } = await supabase.from('profiles').select('id, email, role')
  if (error) {
    console.error('Error fetching audits:', error)
    return
  }
  audits.value = data || []
}
async function fetchSafeguardingCases() {
  const { data, error } = await supabase.from('safeguarding').select('id, type, description')
  if (error) {
    console.error('Error fetching safeguarding cases:', error)
    return
  }
  safeguardingCases.value = data || []
}
</script>
