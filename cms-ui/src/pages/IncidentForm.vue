<template>
  <Layout>
    <nav class="text-xs text-gray-400 mb-2">
      <router-link :to="{ name: 'Dashboard' }" class="hover:underline">Dashboard</router-link> /
      <router-link :to="{ name: 'Incidents' }" class="hover:underline">Incidents</router-link> /
      <span class="text-primary">Report Incident</span>
    </nav>
    <h1 class="font-heading text-2xl mb-6">Report Incident</h1>
    
    <MultiStepForm :steps="steps" @finish="submit">
      <template #default="{ step }">
        <div v-if="step === 0">
          <h2 class="font-heading text-lg mb-2">Incident Details</h2>
          <select v-model="form.type" class="input mb-2 w-full">
            <option value="">Select Type</option>
            <option value="incident">Incident</option>
            <option value="complaint">Complaint</option>
            <option value="compliment">Compliment</option>
          </select>
          <div v-if="errors.type" class="text-error text-xs mb-1">{{ errors.type }}</div>

          <textarea 
            v-model="form.description" 
            placeholder="Description" 
            class="input mb-2 w-full h-32"
          ></textarea>
          <div v-if="errors.description" class="text-error text-xs mb-1">{{ errors.description }}</div>

          <select v-model="form.status" class="input mb-2 w-full">
            <option value="">Select Status</option>
            <option value="open">Open</option>
            <option value="closed">Closed</option>
          </select>
          <div v-if="errors.status" class="text-error text-xs mb-1">{{ errors.status }}</div>
        </div>

        <div v-else-if="step === 1">
          <h2 class="font-heading text-lg mb-2">Assign Users</h2>
          <div class="mb-4">
            <label class="block text-sm font-medium mb-1">Assigned Users</label>
            <div class="grid gap-2">
              <div v-for="user in users" :key="user.id" class="flex items-center">
                <input 
                  type="checkbox" 
                  :id="user.id" 
                  :value="user.id" 
                  v-model="form.assigned_users"
                  class="mr-2"
                >
                <label :for="user.id">{{ user.email }}</label>
              </div>
            </div>
          </div>
          <div v-if="errors.assigned_users" class="text-error text-xs mb-1">{{ errors.assigned_users }}</div>
        </div>

        <div v-else-if="step === 2">
          <h2 class="font-heading text-lg mb-2">Related Items</h2>
          <div class="mb-4">
            <label class="block text-sm font-medium mb-1">Action Plans</label>
            <div class="grid gap-2">
              <div v-for="plan in actionPlans" :key="plan.id" class="flex items-center">
                <input 
                  type="checkbox" 
                  :id="'plan-' + plan.id" 
                  :value="plan.id" 
                  v-model="form.action_plan_ids"
                  class="mr-2"
                >
                <label :for="'plan-' + plan.id">{{ plan.name }}</label>
              </div>
            </div>
          </div>

          <div class="mb-4">
            <label class="block text-sm font-medium mb-1">Audits</label>
            <div class="grid gap-2">
              <div v-for="audit in audits" :key="audit.id" class="flex items-center">
                <input 
                  type="checkbox" 
                  :id="'audit-' + audit.id" 
                  :value="audit.id" 
                  v-model="form.audit_ids"
                  class="mr-2"
                >
                <label :for="'audit-' + audit.id">{{ audit.title }}</label>
              </div>
            </div>
          </div>

          <div class="mb-4">
            <label class="block text-sm font-medium mb-1">Safeguarding Cases</label>
            <div class="grid gap-2">
              <div v-for="caseItem in safeguardingCases" :key="caseItem.id" class="flex items-center">
                <input 
                  type="checkbox" 
                  :id="'case-' + caseItem.id" 
                  :value="caseItem.id" 
                  v-model="form.safeguarding_case_ids"
                  class="mr-2"
                >
                <label :for="'case-' + caseItem.id">{{ caseItem.type }} - {{ caseItem.description }}</label>
              </div>
            </div>
          </div>
        </div>

        <div v-else-if="step === 3">
          <h2 class="font-heading text-lg mb-2">Review</h2>
          <div class="bg-gray-50 p-4 rounded-lg">
            <div class="mb-4">
              <div class="text-sm text-gray-500">Type:</div>
              <div class="font-medium">{{ form.type }}</div>
            </div>
            <div class="mb-4">
              <div class="text-sm text-gray-500">Description:</div>
              <div class="font-medium">{{ form.description }}</div>
            </div>
            <div class="mb-4">
              <div class="text-sm text-gray-500">Status:</div>
              <div class="font-medium">{{ form.status }}</div>
            </div>
            <div class="mb-4">
              <div class="text-sm text-gray-500">Assigned Users:</div>
              <div class="font-medium">
                <div v-for="userId in form.assigned_users" :key="userId">
                  {{ getUserEmail(userId) }}
                </div>
              </div>
            </div>
            <div class="mb-4">
              <div class="text-sm text-gray-500">Action Plans:</div>
              <div class="font-medium">
                <div v-for="planId in form.action_plan_ids" :key="planId">
                  {{ getPlanName(planId) }}
                </div>
              </div>
            </div>
            <div class="mb-4">
              <div class="text-sm text-gray-500">Audits:</div>
              <div class="font-medium">
                <div v-for="auditId in form.audit_ids" :key="auditId">
                  {{ getAuditTitle(auditId) }}
                </div>
              </div>
            </div>
            <div class="mb-4">
              <div class="text-sm text-gray-500">Safeguarding Cases:</div>
              <div class="font-medium">
                <div v-for="caseId in form.safeguarding_case_ids" :key="caseId">
                  {{ getCaseDescription(caseId) }}
                </div>
              </div>
            </div>
          </div>
        </div>
      </template>
    </MultiStepForm>
  </Layout>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import Layout from '../components/Layout.vue'
import MultiStepForm from '../components/MultiStepForm.vue'
import { supabase } from '../supabase'

const router = useRouter()
const steps = [
  { label: 'Details' },
  { label: 'Assign' },
  { label: 'Related' },
  { label: 'Review' }
]

const form = ref({
  type: '',
  description: '',
  status: 'open',
  assigned_users: [],
  action_plan_ids: [],
  audit_ids: [],
  safeguarding_case_ids: []
})

const errors = ref({})
const users = ref([])
const actionPlans = ref([])
const audits = ref([])
const safeguardingCases = ref([])

onMounted(() => {
  fetchUsers()
  fetchActionPlans()
  fetchAudits()
  fetchSafeguardingCases()
})

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

async function fetchActionPlans() {
  const { data, error } = await supabase
    .from('action_plans')
    .select('id, name')
  if (error) {
    console.error('Error fetching action plans:', error)
    return
  }
  actionPlans.value = data || []
}

async function fetchAudits() {
  const { data, error } = await supabase
    .from('audits')
    .select('id, title')
  if (error) {
    console.error('Error fetching audits:', error)
    return
  }
  audits.value = data || []
}

async function fetchSafeguardingCases() {
  const { data, error } = await supabase
    .from('safeguarding')
    .select('id, type, description')
  if (error) {
    console.error('Error fetching safeguarding cases:', error)
    return
  }
  safeguardingCases.value = data || []
}

function validate() {
  errors.value = {}
  if (!form.value.type) errors.value.type = 'Type is required'
  if (!form.value.description) errors.value.description = 'Description is required'
  if (!form.value.status) errors.value.status = 'Status is required'
  if (!form.value.assigned_users.length) errors.value.assigned_users = 'At least one user must be assigned'
  return Object.keys(errors.value).length === 0
}

async function submit() {
  if (!validate()) return

  const { error } = await supabase
    .from('incidents')
    .insert([{
      type: form.value.type,
      description: form.value.description,
      status: form.value.status,
      assigned_users: form.value.assigned_users,
      action_plan_ids: form.value.action_plan_ids,
      audit_ids: form.value.audit_ids,
      safeguarding_case_ids: form.value.safeguarding_case_ids
    }])

  if (error) {
    console.error('Error creating incident:', error)
    return
  }

  // Send notifications to assigned users
  for (const userId of form.value.assigned_users) {
    const user = users.value.find(u => u.id === userId)
    if (user) {
      await supabase.from('notifications').insert({
        user_id: userId,
        type: 'incident_assigned',
        title: 'New Incident Assigned',
        message: `You have been assigned to a new ${form.value.type}: ${form.value.description}`
      })
    }
  }

  router.push({ name: 'Incidents' })
}

function getUserEmail(id) {
  const user = users.value.find(u => u.id === id)
  return user ? user.email : id
}

function getPlanName(id) {
  const plan = actionPlans.value.find(p => p.id === id)
  return plan ? plan.name : id
}

function getAuditTitle(id) {
  const audit = audits.value.find(a => a.id === id)
  return audit ? audit.title : id
}

function getCaseDescription(id) {
  const caseItem = safeguardingCases.value.find(c => c.id === id)
  return caseItem ? `${caseItem.type} - ${caseItem.description}` : id
}
</script>
