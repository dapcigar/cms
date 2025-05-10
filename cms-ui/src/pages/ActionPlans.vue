<template>
  <Layout>
    <div class="flex justify-between items-center mb-6">
      <h1 class="font-heading text-2xl">Action Plans</h1>
      <Button color="primary" @click="showCreate = true">New Action Plan</Button>
    </div>
    <Table>
      <template #header>
        <th class="text-left p-2">Name</th>
        <th class="text-left p-2">Status</th>
        <th class="text-left p-2">Due Date</th>
        <th class="text-left p-2">Assigned Users</th>
        <th class="text-left p-2">Actions</th>
      </template>
      <tr v-for="plan in plans" :key="plan.id">
        <td class="p-2">{{ plan.name }}</td>
        <td class="p-2">{{ plan.status }}</td>
        <td class="p-2">{{ plan.due_date }}</td>
        <td class="p-2">
          <span v-for="user in plan.assigned_users" :key="user" class="inline-block bg-secondary-light text-secondary-dark px-2 py-1 rounded mr-1 text-xs">{{ user }}</span>
        </td>
        <td class="p-2">
          <Button color="secondary" size="sm" @click="editPlan(plan)">Edit</Button>
        </td>
      </tr>
    </Table>
    <Modal :show="showCreate" @close="showCreate = false">
      <h2 class="font-heading text-xl mb-2">Create Action Plan</h2>
      <form @submit.prevent="createPlan">
        <Input v-model="newPlan.name" placeholder="Name" class="mb-2" />
        <Input v-model="newPlan.due_date" type="date" placeholder="Due Date" class="mb-2" />
        <select v-model="newPlan.status" class="mb-2 p-2 border rounded w-full">
          <option value="pending">Pending</option>
          <option value="completed">Completed</option>
        </select>
        <select v-model="newPlan.assigned_users" multiple class="mb-4 p-2 border rounded w-full">
          <option v-for="user in users" :key="user.id" :value="user.id">{{ user.name }}</option>
        </select>
        <Button color="primary" class="w-full">Create</Button>
      </form>
    </Modal>
    <Modal :show="!!editTarget" @close="editTarget = null">
      <h2 class="font-heading text-xl mb-2">Edit Action Plan</h2>
      <form @submit.prevent="updatePlan">
        <Input v-model="editTarget.name" placeholder="Name" class="mb-2" />
        <Input v-model="editTarget.due_date" type="date" placeholder="Due Date" class="mb-2" />
        <select v-model="editTarget.status" class="mb-2 p-2 border rounded w-full">
          <option value="pending">Pending</option>
          <option value="completed">Completed</option>
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

const plans = ref<any[]>([])
const users = ref<any[]>([])
const showCreate = ref(false)
const newPlan = ref({ name: '', status: 'pending', due_date: '', assigned_users: [] })
const editTarget = ref<any | null>(null)

async function fetchPlans() {
  const { data, error } = await supabase.from('action_plans').select('*')
  if (!error) plans.value = data || []
}
async function fetchUsers() {
  const { data, error } = await supabase.from('users').select('id, name')
  if (!error) users.value = data || []
}
let planSubscription: any = null
onMounted(() => {
  fetchPlans();
  fetchUsers();
  // Real-time updates
  planSubscription = supabase
    .channel('action_plans')
    .on('postgres_changes', { event: '*', schema: 'public', table: 'action_plans' }, payload => {
      fetchPlans()
    })
    .subscribe()
})
onUnmounted(() => {
  if (planSubscription) supabase.removeChannel(planSubscription)
})

async function createPlan() {
  await supabase.from('action_plans').insert([
    {
      name: newPlan.value.name,
      status: newPlan.value.status,
      due_date: newPlan.value.due_date,
      assigned_users: newPlan.value.assigned_users,
    },
  ])
  showCreate.value = false
  fetchPlans()
}

function editPlan(plan: any) {
  editTarget.value = { ...plan }
}

async function updatePlan() {
  if (!editTarget.value) return
  await supabase.from('action_plans').update({
    name: editTarget.value.name,
    status: editTarget.value.status,
    due_date: editTarget.value.due_date,
    assigned_users: editTarget.value.assigned_users,
  }).eq('id', editTarget.value.id)
  editTarget.value = null
  fetchPlans()
}
</script>
