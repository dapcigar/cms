<template>
  <Layout>
    <div class="flex justify-between items-center mb-6">
      <h1 class="font-heading text-2xl">User Management</h1>
      <Button v-if="isAdmin" color="primary" @click="showCreate = true">Add User</Button>
    </div>
    <Card class="overflow-hidden">
      <Table>
        <template #header>
          <th class="text-left p-4 bg-gray-50 font-medium text-slate-800">Name</th>
          <th class="text-left p-4 bg-gray-50 font-medium text-slate-800">Email</th>
          <th class="text-left p-4 bg-gray-50 font-medium text-slate-800">Role</th>
          <th class="text-left p-4 bg-gray-50 font-medium text-slate-800">Actions</th>
        </template>
        <tr v-for="user in users" :key="user.id" class="border-t border-gray-100 hover:bg-gray-50/50">
          <td class="p-4">{{ user.name }}</td>
          <td class="p-4">{{ user.email }}</td>
          <td class="p-4">
            <span :class="{
              'bg-primary/10 text-primary': user.role === 'admin',
              'bg-success/10 text-success': user.role === 'staff'
            }" class="px-2 py-1 rounded-full text-sm font-medium capitalize">
              {{ user.role }}
            </span>
          </td>
          <td class="p-4">
            <Button v-if="isAdmin" color="primary" size="sm" @click="editUser(user)">Edit</Button>
          </td>
        </tr>
        <tr v-if="users.length === 0">
          <td colspan="4" class="p-4 text-center text-gray-500">No users found</td>
        </tr>
      </Table>
    </Card>

    <Modal :show="showCreate" @close="showCreate = false">
      <h2 class="font-heading text-xl mb-4">Create User</h2>
      <form @submit.prevent="createUser" class="space-y-4">
        <div>
          <label class="block text-sm font-medium mb-1">Name</label>
          <Input v-model="newUser.name" placeholder="Enter name" />
        </div>
        <div>
          <label class="block text-sm font-medium mb-1">Email</label>
          <Input v-model="newUser.email" type="email" placeholder="Enter email" />
        </div>
        <div>
          <label class="block text-sm font-medium mb-1">Password</label>
          <Input v-model="newUser.password" type="password" placeholder="Enter password" />
        </div>
        <div v-if="isAdmin">
          <label class="block text-sm font-medium mb-1">Role</label>
          <select v-model="newUser.role" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary">
            <option value="admin">Admin</option>
            <option value="staff">Staff</option>
          </select>
        </div>
        <Button type="submit" color="primary" class="w-full">Create User</Button>
      </form>
    </Modal>

    <Modal :show="!!editTarget" @close="editTarget = null">
      <h2 class="font-heading text-xl mb-4">Edit User</h2>
      <form v-if="editTarget" @submit.prevent="updateUser" class="space-y-4">
        <div>
          <label class="block text-sm font-medium mb-1">Name</label>
          <Input v-model="editTarget.name" placeholder="Enter name" />
        </div>
        <div>
          <label class="block text-sm font-medium mb-1">Email</label>
          <Input v-model="editTarget.email" type="email" placeholder="Enter email" />
        </div>
        <div v-if="isAdmin">
          <label class="block text-sm font-medium mb-1">Role</label>
          <select v-model="editTarget.role" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary">
            <option value="admin">Admin</option>
            <option value="staff">Staff</option>
          </select>
        </div>
        <Button type="submit" color="primary" class="w-full">Update User</Button>
      </form>
    </Modal>
  </Layout>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import Layout from '../components/Layout.vue'
import Table from '../components/Table.vue'
import Card from '../components/Card.vue'
import Button from '../components/Button.vue'
import Modal from '../components/Modal.vue'
import Input from '../components/Input.vue'
import { supabase } from '../supabase'

// Placeholder: Replace with real logic to get current user's role
const currentUser = ref({ role: 'admin' }) // or 'staff' for testing
const isAdmin = computed(() => currentUser.value.role === 'admin')

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
