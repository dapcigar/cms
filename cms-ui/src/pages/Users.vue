<template>
  <Layout>
    <div class="flex justify-between items-center mb-6">
      <h1 class="font-heading text-2xl">User Management</h1>
      <Button color="primary" @click="showCreate = true">Add User</Button>
    </div>
    <Table>
      <template #header>
        <th class="text-left p-2">Name</th>
        <th class="text-left p-2">Email</th>
        <th class="text-left p-2">Role</th>
        <th class="text-left p-2">Actions</th>
      </template>
      <tr v-for="user in users" :key="user.id">
        <td class="p-2">{{ user.name }}</td>
        <td class="p-2">{{ user.email }}</td>
        <td class="p-2">{{ user.role }}</td>
        <td class="p-2">
          <Button color="secondary" size="sm" @click="editUser(user)">Edit</Button>
        </td>
      </tr>
    </Table>
    <Modal :show="showCreate" @close="showCreate = false">
      <h2 class="font-heading text-xl mb-2">Create User</h2>
      <form @submit.prevent="createUser">
        <Input v-model="newUser.name" placeholder="Name" class="mb-2" />
        <Input v-model="newUser.email" placeholder="Email" class="mb-2" />
        <Input v-model="newUser.password" type="password" placeholder="Password" class="mb-2" />
        <select v-model="newUser.role" class="mb-4 p-2 border rounded w-full">
          <option value="admin">Admin</option>
          <option value="staff">Staff</option>
        </select>
        <Button color="primary" class="w-full">Create</Button>
      </form>
    </Modal>
    <Modal :show="!!editTarget" @close="editTarget = null">
      <h2 class="font-heading text-xl mb-2">Edit User</h2>
      <form @submit.prevent="updateUser">
        <Input v-model="editTarget.name" placeholder="Name" class="mb-2" />
        <Input v-model="editTarget.email" placeholder="Email" class="mb-2" />
        <select v-model="editTarget.role" class="mb-4 p-2 border rounded w-full">
          <option value="admin">Admin</option>
          <option value="staff">Staff</option>
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

const users = ref<any[]>([])
const showCreate = ref(false)
const newUser = ref({ name: '', email: '', password: '', role: 'staff' })
const editTarget = ref<any | null>(null)

async function fetchUsers() {
  const { data, error } = await supabase.from('users').select('*')
  if (!error) users.value = data || []
}
onMounted(fetchUsers)

async function createUser() {
  // Create user in Supabase Auth and store profile in users table
  const { data, error } = await supabase.auth.admin.createUser({
    email: newUser.value.email,
    password: newUser.value.password,
    user_metadata: { name: newUser.value.name, role: newUser.value.role },
  })
  if (!error) {
    await supabase.from('users').insert([
      { id: data.user.id, name: newUser.value.name, email: newUser.value.email, role: newUser.value.role },
    ])
    showCreate.value = false
    fetchUsers()
  }
}

function editUser(user: any) {
  editTarget.value = { ...user }
}

async function updateUser() {
  if (!editTarget.value) return
  await supabase.from('users').update({
    name: editTarget.value.name,
    email: editTarget.value.email,
    role: editTarget.value.role,
  }).eq('id', editTarget.value.id)
  editTarget.value = null
  fetchUsers()
}
</script>
