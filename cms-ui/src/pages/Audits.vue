<template>
  <Layout>
    <div class="flex justify-between items-center mb-6">
      <h1 class="font-heading text-2xl">Audits</h1>
      <Button color="primary" @click="showCreate = true">New Audit</Button>
    </div>
    <Table>
      <template #header>
        <th class="text-left p-2">Title</th>
        <th class="text-left p-2">Status</th>
        <th class="text-left p-2">Assigned Users</th>
        <th class="text-left p-2">Actions</th>
      </template>
      <tr v-for="audit in audits" :key="audit.id">
        <td class="p-2">{{ audit.title }}</td>
        <td class="p-2">{{ audit.status }}</td>
        <td class="p-2">
          <span v-for="user in audit.assigned_users" :key="user" class="inline-block bg-primary-light text-primary-dark px-2 py-1 rounded mr-1 text-xs">{{ user }}</span>
        </td>
        <td class="p-2">
          <Button color="secondary" size="sm" @click="editAudit(audit)">Edit</Button>
        </td>
      </tr>
    </Table>
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
import { ref, onMounted } from 'vue'
import Layout from '../components/Layout.vue'
import Table from '../components/Table.vue'
import Button from '../components/Button.vue'
import Modal from '../components/Modal.vue'
import Input from '../components/Input.vue'
import { supabase } from '../supabase'

const audits = ref<any[]>([])
const users = ref<any[]>([])
const showCreate = ref(false)
const newAudit = ref({ title: '', status: 'open', assigned_users: [] })
const editTarget = ref<any | null>(null)

async function fetchAudits() {
  const { data, error } = await supabase.from('audits').select('*')
  if (!error) audits.value = data || []
}
async function fetchUsers() {
  const { data, error } = await supabase.from('users').select('id, name')
  if (!error) users.value = data || []
}
onMounted(() => { fetchAudits(); fetchUsers() })

async function createAudit() {
  await supabase.from('audits').insert([
    {
      title: newAudit.value.title,
      status: newAudit.value.status,
      assigned_users: newAudit.value.assigned_users,
    },
  ])
  showCreate.value = false
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
  editTarget.value = null
  fetchAudits()
}
</script>
