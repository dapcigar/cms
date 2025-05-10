<template>
  <Layout>
    <div class="flex justify-between items-center mb-6">
      <h1 class="font-heading text-2xl">Action Plans</h1>
      <Button color="primary" @click="showCreate = true">New Action Plan</Button>
    </div>
    <div v-if="loading" class="flex items-center justify-center py-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
    </div>

    <div v-else-if="!plans.length" class="text-center py-12">
      <div class="text-gray-500 mb-4">No action plans found</div>
      <Button color="primary" @click="showCreate = true">Create Your First Plan</Button>
    </div>

    <div v-else class="grid gap-6 grid-cols-1 sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-4">
      <router-link
        v-for="plan in plans"
        :key="plan.id"
        :to="{ name: 'ActionPlanDetail', params: { id: plan.id } }"
        class="block card shadow-lg border border-gray-100 hover:shadow-xl transition-all bg-white p-4 rounded-lg no-underline"
      >
        <div class="flex items-center justify-between mb-3">
          <h3 class="font-bold text-lg text-primary truncate mr-2">{{ plan.name }}</h3>
          <span :class="[
            'rounded-full px-3 py-1 text-xs font-semibold whitespace-nowrap',
            plan.status === 'completed' ? 'bg-success/10 text-success' : 'bg-secondary/10 text-secondary'
          ]">
            {{ plan.status.charAt(0).toUpperCase() + plan.status.slice(1) }}
          </span>
        </div>

        <div class="space-y-3">
          <div>
            <div class="text-xs text-gray-500 mb-1">Due Date</div>
            <div class="text-sm font-medium">
              {{ formatDate(plan.due_date) || 'Not set' }}
            </div>
          </div>

          <div>
            <div class="text-xs text-gray-500 mb-1">Assigned Users</div>
            <div class="flex flex-wrap gap-1">
              <span 
                v-for="userId in plan.assigned_users" 
                :key="userId" 
                class="inline-flex items-center gap-1 bg-primary/10 text-primary px-2 py-1 rounded-full text-xs font-medium"
              >
                <i class="material-icons text-sm">person</i>
                {{ getUserName(userId) }}
              </span>
              <span v-if="!plan.assigned_users?.length" class="text-gray-400 text-sm">No users assigned</span>
            </div>
          </div>
        </div>

        <div class="mt-4 flex justify-end">
          <Button 
            color="secondary" 
            size="sm" 
            class="opacity-0 group-hover:opacity-100 transition-opacity"
            @click.prevent="editPlan(plan)"
          >
            <i class="material-icons text-sm mr-1">edit</i>
            Edit
          </Button>
        </div>
      </router-link>
    </div>
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
import { ref, onMounted, onUnmounted } from 'vue'
import Layout from '../components/Layout.vue'
import Button from '../components/Button.vue'
import Modal from '../components/Modal.vue'
import Input from '../components/Input.vue'
import { supabase } from '../supabase'

const plans = ref<any[]>([])
const users = ref<any[]>([])
const loading = ref(true)
const showCreate = ref(false)
const errors = ref({
  name: '',
  due_date: '',
  assigned_users: ''
})

const newPlan = ref({
  name: '',
  status: 'pending',
  due_date: '',
  assigned_users: []
})

const editTarget = ref<any | null>(null)

function getUserName(id: string) {
  const user = users.value.find(u => u.id === id)
  return user ? user.name : id
}

function formatDate(date: string) {
  if (!date) return ''
  return new Date(date).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

async function fetchPlans() {
  const { data, error } = await supabase
    .from('action_plans')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) {
    console.error('Error fetching plans:', error)
    return
  }

  plans.value = data || []
  loading.value = false
}

async function fetchUsers() {
  const { data, error } = await supabase
    .from('users')
    .select('id, name')
    .order('name')

  if (error) {
    console.error('Error fetching users:', error)
    return
  }

  users.value = data || []
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
  // Reset errors
  errors.value = {
    name: '',
    due_date: '',
    assigned_users: ''
  }

  // Validate
  if (!newPlan.value.name.trim()) {
    errors.value.name = 'Name is required'
    return
  }

  if (!newPlan.value.due_date) {
    errors.value.due_date = 'Due date is required'
    return
  }

  loading.value = true

  try {
    const { data, error } = await supabase
      .from('action_plans')
      .insert([{
        name: newPlan.value.name.trim(),
        status: newPlan.value.status,
        due_date: newPlan.value.due_date,
        assigned_users: newPlan.value.assigned_users,
        created_at: new Date().toISOString()
      }])
      .select()
      .single()

    if (error) throw error

    // Notify assigned users
    await Promise.all(newPlan.value.assigned_users.map(userId =>
      supabase.from('notifications').insert({
        user_id: userId,
        title: 'New Action Plan Assigned',
        message: `You have been assigned to the action plan: ${newPlan.value.name}`,
        created_at: new Date().toISOString()
      })
    ))

    showCreate.value = false
    newPlan.value = { name: '', status: 'pending', due_date: '', assigned_users: [] }
    await fetchPlans()
  } catch (error) {
    console.error('Error creating plan:', error)
  } finally {
    loading.value = false
  }
}

function editPlan(plan: any) {
  editTarget.value = { ...plan }
}

async function updatePlan() {
  if (!editTarget.value) return

  // Reset errors
  errors.value = {
    name: '',
    due_date: '',
    assigned_users: ''
  }

  // Validate
  if (!editTarget.value.name.trim()) {
    errors.value.name = 'Name is required'
    return
  }

  if (!editTarget.value.due_date) {
    errors.value.due_date = 'Due date is required'
    return
  }

  loading.value = true

  try {
    const { error } = await supabase
      .from('action_plans')
      .update({
        name: editTarget.value.name.trim(),
        status: editTarget.value.status,
        due_date: editTarget.value.due_date,
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
        title: 'Action Plan Assignment',
        message: `You have been assigned to the action plan: ${editTarget.value.name}`,
        created_at: new Date().toISOString()
      })
    ))

    editTarget.value = null
    await fetchPlans()
  } catch (error) {
    console.error('Error updating plan:', error)
  } finally {
    loading.value = false
  }
}
</script>
