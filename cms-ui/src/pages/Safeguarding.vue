<template>
  <Layout>
    <div class="flex justify-between items-center mb-6">
      <h1 class="font-heading text-2xl">Safeguarding Cases</h1>
      <router-link :to="{ name: 'SafeguardingLogForm' }">
        <Button color="primary">New Safeguarding Case</Button>
      </router-link>
    </div>

    <div v-if="loading" class="flex items-center justify-center py-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
    </div>

    <div v-else-if="!cases.length" class="text-center py-12">
      <div class="text-gray-500 mb-4">No safeguarding cases found</div>
      <Button color="primary" @click="showCreate = true">Create Your First Case</Button>
    </div>

    <div v-else class="bg-white rounded-lg shadow border border-gray-200 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th 
                v-for="header in headers" 
                :key="header.key"
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer"
                @click="sortBy(header.key)"
              >
                <div class="flex items-center">
                  {{ header.label }}
                  <span v-if="sortField === header.key" class="ml-1">
                    {{ sortDirection === 'asc' ? '↑' : '↓' }}
                  </span>
                </div>
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="caseItem in paginatedCases" :key="caseItem.id" class="hover:bg-gray-50">
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm font-medium text-primary">{{ caseItem.type }}</div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm text-gray-900">{{ caseItem.description }}</div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span :class="[
                  'px-2 py-1 text-xs font-semibold rounded-full',
                  caseItem.status === 'open' ? 'bg-success text-white' : 'bg-secondary text-white'
                ]">
                  {{ caseItem.status.charAt(0).toUpperCase() + caseItem.status.slice(1) }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm text-gray-500">
                  {{ new Date(caseItem.created_at).toLocaleDateString() }}
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex flex-wrap gap-1">
                  <span 
                    v-for="userId in caseItem.assigned_users" 
                    :key="userId" 
                    class="inline-block bg-accent/10 text-accent px-2 py-1 rounded-full text-xs font-medium"
                  >
                    {{ getUserName(userId) }}
                  </span>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <Button 
                  color="secondary" 
                  size="sm" 
                  class="mr-2"
                  @click="editCase(caseItem)"
                >
                  Edit
                </Button>
                <router-link 
                  :to="{ name: 'SafeguardingDetail', params: { id: caseItem.id } }"
                >
                  <Button color="primary" size="sm">
                    View
                  </Button>
                </router-link>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      
      <div class="bg-gray-50 px-6 py-3 flex items-center justify-between border-t border-gray-200">
        <div class="text-sm text-gray-500">
          Showing {{ startItem }}-{{ endItem }} of {{ cases.length }} cases
        </div>
        <div class="flex items-center space-x-2">
          <Button 
            color="secondary" 
            size="sm"
            :disabled="currentPage === 1"
            @click="currentPage = 1"
          >
            First
          </Button>
          <Button 
            color="secondary" 
            size="sm"
            :disabled="currentPage === 1"
            @click="currentPage--"
          >
            Previous
          </Button>
          <span class="px-3 py-1 text-sm text-gray-700">
            Page {{ currentPage }} of {{ totalPages }}
          </span>
          <Button 
            color="secondary" 
            size="sm"
            :disabled="currentPage === totalPages"
            @click="currentPage++"
          >
            Next
          </Button>
          <Button 
            color="secondary" 
            size="sm"
            :disabled="currentPage === totalPages"
            @click="currentPage = totalPages"
          >
            Last
          </Button>
        </div>
      </div>
    </div>

    <Modal :show="showCreate" @close="showCreate = false">
      <h2 class="font-heading text-xl mb-2">Create Safeguarding Case</h2>
      <form @submit.prevent="createCase">
        <Input v-model="newCase.type" placeholder="Type" class="mb-2" />
        <Input v-model="newCase.description" placeholder="Description" class="mb-2" />
        <select v-model="newCase.status" class="mb-2 p-2 border rounded w-full">
          <option value="open">Open</option>
          <option value="resolved">Resolved</option>
        </select>
        <select v-model="newCase.assigned_users" multiple class="mb-4 p-2 border rounded w-full">
          <option v-for="user in users" :key="user.id" :value="user.id">{{ user.name }}</option>
        </select>
        <Button color="primary" class="w-full">Create</Button>
      </form>
    </Modal>
    <Modal :show="!!editTarget" @close="editTarget = null">
      <h2 class="font-heading text-xl mb-2">Edit Safeguarding Case</h2>
      <form @submit.prevent="updateCase">
        <Input v-model="editTarget.type" placeholder="Type" class="mb-2" />
        <Input v-model="editTarget.description" placeholder="Description" class="mb-2" />
        <select v-model="editTarget.status" class="mb-2 p-2 border rounded w-full">
          <option value="open">Open</option>
          <option value="resolved">Resolved</option>
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
import { ref, onMounted, onUnmounted, computed } from 'vue'
import Layout from '../components/Layout.vue'
import Button from '../components/Button.vue'
import Modal from '../components/Modal.vue'
import Input from '../components/Input.vue'
import { supabase } from '../supabase'

const cases = ref<any[]>([])
const users = ref<any[]>([])
const loading = ref(true)
const showCreate = ref(false)
const errors = ref({
  type: '',
  description: ''
})

const newCase = ref({
  type: '',
  description: '',
  status: 'open',
  assigned_users: []
})

const editTarget = ref<any | null>(null)
let safeguardingSubscription: any = null

const sortField = ref('created_at')
const sortDirection = ref('desc')

const headers = [
  { key: 'type', label: 'Type' },
  { key: 'description', label: 'Description' },
  { key: 'status', label: 'Status' },
  { key: 'created_at', label: 'Date Created' },
  { key: 'assigned_users', label: 'Assigned To' }
]

const sortedCases = computed(() => {
  return [...cases.value].sort((a, b) => {
    let compare = 0
    
    if (a[sortField.value] > b[sortField.value]) {
      compare = 1
    } else if (a[sortField.value] < b[sortField.value]) {
      compare = -1
    }
    
    return sortDirection.value === 'desc' ? compare * -1 : compare
  })
})

const itemsPerPage = 10
const currentPage = ref(1)

const totalPages = computed(() => {
  return Math.ceil(cases.value.length / itemsPerPage)
})

const startItem = computed(() => {
  return (currentPage.value - 1) * itemsPerPage + 1
})

const endItem = computed(() => {
  return Math.min(currentPage.value * itemsPerPage, cases.value.length)
})

const paginatedCases = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return sortedCases.value.slice(start, end)
})

function getUserName(id: string) {
  const user = users.value.find(u => u.id === id)
  return user ? user.email : id
}

async function fetchCases() {
  console.log('Fetching safeguarding cases...')
  const { data, error } = await supabase
    .from('safeguarding')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) {
    console.error('Error fetching cases:', error)
    return
  }

  console.log('Cases data received:', data)
  cases.value = data || []
  loading.value = false
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

onMounted(() => {
  fetchCases();
  fetchUsers();
  // Real-time updates
  safeguardingSubscription = supabase
    .channel('safeguarding')
    .on('postgres_changes', { event: '*', schema: 'public', table: 'safeguarding' }, payload => {
      fetchCases()
    })
    .subscribe()
})

onUnmounted(() => {
  if (safeguardingSubscription) supabase.removeChannel(safeguardingSubscription)
})

async function createCase() {
  // Reset errors
  errors.value = {
    type: '',
    description: ''
  }

  // Validate
  if (!newCase.value.type.trim()) {
    errors.value.type = 'Type is required'
    return
  }

  if (!newCase.value.description.trim()) {
    errors.value.description = 'Description is required'
    return
  }

  loading.value = true

  try {
    const { data, error } = await supabase
      .from('safeguarding')
      .insert([{
        type: newCase.value.type.trim(),
        description: newCase.value.description.trim(),
        status: newCase.value.status,
        assigned_users: newCase.value.assigned_users,
        created_at: new Date().toISOString()
      }])
      .select()
      .single()

    if (error) throw error

    // Notify assigned users
    await Promise.all(newCase.value.assigned_users.map(userId =>
      supabase.from('notifications').insert({
        user_id: userId,
        title: 'New Safeguarding Case',
        message: `You have been assigned to a new safeguarding case: ${newCase.value.type}`,
        created_at: new Date().toISOString()
      })
    ))

    showCreate.value = false
    newCase.value = { type: '', description: '', status: 'open', assigned_users: [] }
    await fetchCases()
  } catch (error) {
    console.error('Error creating case:', error)
  } finally {
    loading.value = false
  }
}

function editCase(caseItem: any) {
  editTarget.value = { ...caseItem }
}

async function updateCase() {
  if (!editTarget.value) return

  // Reset errors
  errors.value = {
    type: '',
    description: ''
  }

  // Validate
  if (!editTarget.value.type.trim()) {
    errors.value.type = 'Type is required'
    return
  }

  if (!editTarget.value.description.trim()) {
    errors.value.description = 'Description is required'
    return
  }

  loading.value = true

  try {
    const { error } = await supabase
      .from('safeguarding')
      .update({
        type: editTarget.value.type.trim(),
        description: editTarget.value.description.trim(),
        status: editTarget.value.status,
        assigned_users: editTarget.value.assigned_users,
        updated_at: new Date().toISOString()
      })
      .eq('id', editTarget.value.id)

    if (error) throw error

    // Notify newly assigned users
    const newAssignees = editTarget.value.assigned_users.filter(
      (userId: string) => !editTarget.value.original_assigned_users.includes(userId)
    )

    await Promise.all(newAssignees.map(userId =>
      supabase.from('notifications').insert({
        user_id: userId,
        title: 'Safeguarding Case Assignment',
        message: `You have been assigned to a safeguarding case: ${editTarget.value.type}`,
        created_at: new Date().toISOString()
      })
    ))

    editTarget.value = null
    await fetchCases()
  } catch (error) {
    console.error('Error updating case:', error)
  } finally {
    loading.value = false
  }
}

function sortBy(field: string) {
  if (sortField.value === field) {
    sortDirection.value = sortDirection.value === 'asc' ? 'desc' : 'asc'
  } else {
    sortField.value = field
    sortDirection.value = 'desc'
  }
}
</script>
