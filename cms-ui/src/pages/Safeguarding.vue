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

    <div v-else class="grid gap-6 grid-cols-1 sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-4">
      <router-link
        v-for="caseItem in cases"
        :key="caseItem.id"
        :to="{ name: 'SafeguardingDetail', params: { id: caseItem.id } }"
        class="block card shadow-lg border border-gray-100 hover:shadow-xl transition-all bg-white p-4 rounded-lg no-underline group"
      >
        <div class="flex items-center justify-between mb-2">
          <span :class="[
            'rounded-full px-3 py-1 text-xs font-semibold',
            caseItem.type.toLowerCase().includes('risk') ? 'bg-error text-white' : 'bg-accent text-white'
          ]">
            {{ caseItem.type }}
          </span>
          <span :class="[
            'rounded-full px-3 py-1 text-xs font-semibold',
            caseItem.status === 'open' ? 'bg-success text-white' : 'bg-secondary text-white'
          ]">
            {{ caseItem.status.charAt(0).toUpperCase() + caseItem.status.slice(1) }}
          </span>
        </div>
        <div class="mb-2">
          <div class="text-xs text-gray-500 mb-1">Description:</div>
          <div class="text-base text-primary font-medium">{{ caseItem.description }}</div>
        </div>
        <div class="mb-2">
          <div class="text-xs text-gray-500 mb-1">Assigned Users:</div>
          <div class="flex flex-wrap gap-1">
            <span v-for="userId in caseItem.assigned_users" :key="userId" class="inline-block bg-accent/10 text-accent px-2 py-1 rounded-full text-xs font-medium">
              {{ getUserName(userId) }}
            </span>
          </div>
        </div>
        <div class="mt-auto flex gap-2">
          <Button color="secondary" size="sm" @click.prevent="editCase(caseItem)">Edit</Button>
        </div>
      </router-link>
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
import { ref, onMounted, onUnmounted } from 'vue'
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

function getUserName(id: string) {
  const user = users.value.find(u => u.id === id)
  return user ? user.email : id
}

async function fetchCases() {
  const { data, error } = await supabase
    .from('safeguarding')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) {
    console.error('Error fetching cases:', error)
    return
  }

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
</script>
