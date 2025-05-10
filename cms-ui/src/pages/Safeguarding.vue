<template>
  <Layout>
    <div class="flex justify-between items-center mb-6">
      <h1 class="font-heading text-2xl">Safeguarding Cases</h1>
      <Button color="primary" @click="showCreate = true">New Case</Button>
    </div>
    <div class="grid gap-6 grid-cols-1 sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-4">
      <div v-for="caseItem in cases" :key="caseItem.id" class="card shadow-lg border border-gray-100 hover:shadow-xl transition-all bg-white flex flex-col">
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
          <Button color="secondary" size="sm" @click="editCase(caseItem)">Edit</Button>
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
import { ref, onMounted } from 'vue'
import Layout from '../components/Layout.vue'
import Table from '../components/Table.vue'
import Button from '../components/Button.vue'
import Modal from '../components/Modal.vue'
import Input from '../components/Input.vue'
import { supabase } from '../supabase'

const cases = ref<any[]>([])
const users = ref<any[]>([])
const showCreate = ref(false)
const newCase = ref({ type: '', description: '', status: 'open', assigned_users: [] })
const editTarget = ref<any | null>(null)

function getUserName(id: string) {
  const user = users.value.find(u => u.id === id)
  return user ? user.name : id
}

async function fetchCases() {
  const { data, error } = await supabase.from('safeguarding').select('*')
  if (!error) cases.value = data || []
}
async function fetchUsers() {
  const { data, error } = await supabase.from('users').select('id, name')
  if (!error) users.value = data || []
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
  await supabase.from('safeguarding').insert([
    {
      type: newCase.value.type,
      description: newCase.value.description,
      status: newCase.value.status,
      assigned_users: newCase.value.assigned_users,
    },
  ])
  showCreate.value = false
  fetchCases()
}

function editCase(caseItem: any) {
  editTarget.value = { ...caseItem }
}

async function updateCase() {
  if (!editTarget.value) return
  await supabase.from('safeguarding').update({
    type: editTarget.value.type,
    description: editTarget.value.description,
    status: editTarget.value.status,
    assigned_users: editTarget.value.assigned_users,
  }).eq('id', editTarget.value.id)
  editTarget.value = null
  fetchCases()
}
</script>
