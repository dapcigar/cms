<template>
  <Layout>
    <nav class="breadcrumb">
      <router-link :to="{ name: 'Dashboard' }" class="breadcrumb-link">Dashboard</router-link> /
      <router-link :to="{ name: 'Incidents' }" class="breadcrumb-link">Incidents</router-link> /
      <span class="breadcrumb-current">Report Incident</span>
    </nav>
    <h1 class="page-title">Report Incident</h1>
    
    <div class="form-container">
      <MultiStepForm :steps="steps" @finish="submit">
        <template #default="{ step }">
          <div v-if="step === 0">
            <h2 class="section-title">Incident Details</h2>
            <div class="form-group">
              <label class="form-label">Type</label>
              <select v-model="form.type" class="form-select">
                <option value="">Select Type</option>
                <option value="incident">Incident</option>
                <option value="complaint">Complaint</option>
                <option value="compliment">Compliment</option>
              </select>
              <div v-if="errors.type" class="form-error">{{ errors.type }}</div>
            </div>

            <div class="form-group">
              <label class="form-label">Description</label>
              <textarea 
                v-model="form.description" 
                placeholder="Enter a detailed description" 
                class="form-textarea"
              ></textarea>
              <div v-if="errors.description" class="form-error">{{ errors.description }}</div>
            </div>

            <div class="form-group">
              <label class="form-label">Status</label>
              <select v-model="form.status" class="form-select">
                <option value="">Select Status</option>
                <option value="open">Open</option>
                <option value="closed">Closed</option>
              </select>
              <div v-if="errors.status" class="form-error">{{ errors.status }}</div>
            </div>
          </div>

          <div v-else-if="step === 1">
            <h2 class="section-title">Assign Users</h2>
            <div class="form-group">
              <label class="form-label">Assigned Users</label>
              <select 
                multiple 
                v-model="form.assigned_users" 
                class="form-select" 
                required
              >
                <option v-for="user in users" :key="user.id" :value="user.id">
                  {{ user.email }}
                </option>
              </select>
              <p class="form-help">Hold Ctrl/Cmd to select multiple users</p>
              <div v-if="errors.assigned_users" class="form-error">{{ errors.assigned_users }}</div>
            </div>
          </div>

          <div v-else-if="step === 2">
            <h2 class="section-title">Related Items</h2>
            <p class="section-description">Link this incident to relevant action plans, audits, and safeguarding cases</p>
            
            <div class="form-group">
              <div class="flex justify-between items-center mb-2">
                <label class="form-label mb-0">Action Plans</label>
                <Button 
                  v-if="actionPlans.length === 0" 
                  color="primary" 
                  size="sm" 
                  @click="showCreateActionPlan = true"
                >
                  Create New
                </Button>
              </div>
              <div class="checkbox-group">
                <div v-for="plan in actionPlans" :key="plan.id" class="checkbox-item">
                  <input 
                    type="checkbox" 
                    :id="'plan-' + plan.id" 
                    :value="plan.id" 
                    v-model="form.action_plan_ids"
                    class="checkbox-input"
                  >
                  <label :for="'plan-' + plan.id" class="checkbox-label">{{ plan.name }}</label>
                </div>
                <div v-if="actionPlans.length === 0" class="empty-state">No action plans available</div>
              </div>
            </div>

            <div class="form-group">
              <label class="form-label">Audits</label>
              <div class="checkbox-group">
                <div v-for="audit in audits" :key="audit.id" class="checkbox-item">
                  <input 
                    type="checkbox" 
                    :id="'audit-' + audit.id" 
                    :value="audit.id" 
                    v-model="form.audit_ids"
                    class="checkbox-input"
                  >
                  <label :for="'audit-' + audit.id" class="checkbox-label">{{ audit.title }}</label>
                </div>
                <div v-if="audits.length === 0" class="empty-state">No audits available</div>
              </div>
            </div>

            <div class="form-group">
              <div class="flex justify-between items-center mb-2">
                <label class="form-label mb-0">Safeguarding Cases</label>
                <Button 
                  v-if="safeguardingCases.length === 0" 
                  color="primary" 
                  size="sm" 
                  @click="showCreateSafeguardingCase = true"
                >
                  Create New
                </Button>
              </div>
              <div class="checkbox-group">
                <div v-for="caseItem in safeguardingCases" :key="caseItem.id" class="checkbox-item">
                  <input 
                    type="checkbox" 
                    :id="'case-' + caseItem.id" 
                    :value="caseItem.id" 
                    v-model="form.safeguarding_case_ids"
                    class="checkbox-input"
                  >
                  <label :for="'case-' + caseItem.id" class="checkbox-label">{{ caseItem.type }} - {{ caseItem.description }}</label>
                </div>
                <div v-if="safeguardingCases.length === 0" class="empty-state">No safeguarding cases available</div>
              </div>
            </div>
          </div>

          <div v-else-if="step === 3">
            <h2 class="section-title">Review</h2>
            <p class="section-description">Please review the information before submitting</p>
            <div class="review-container">
              <div class="review-item">
                <div class="review-label">Type:</div>
                <div class="review-value">{{ form.type }}</div>
              </div>
              <div class="review-item">
                <div class="review-label">Description:</div>
                <div class="review-value">{{ form.description }}</div>
              </div>
              <div class="review-item">
                <div class="review-label">Status:</div>
                <div class="review-value">{{ form.status }}</div>
              </div>
              <div class="review-item">
                <div class="review-label">Assigned Users:</div>
                <div class="review-value">
                  <div v-for="userId in form.assigned_users" :key="userId" class="review-list-item">
                    {{ getUserEmail(userId) }}
                  </div>
                  <div v-if="form.assigned_users.length === 0" class="review-empty">None selected</div>
                </div>
              </div>
              <div class="review-item">
                <div class="review-label">Action Plans:</div>
                <div class="review-value">
                  <div v-for="planId in form.action_plan_ids" :key="planId" class="review-list-item">
                    {{ getPlanName(planId) }}
                  </div>
                  <div v-if="form.action_plan_ids.length === 0" class="review-empty">None selected</div>
                </div>
              </div>
              <div class="review-item">
                <div class="review-label">Audits:</div>
                <div class="review-value">
                  <div v-for="auditId in form.audit_ids" :key="auditId" class="review-list-item">
                    {{ getAuditTitle(auditId) }}
                  </div>
                  <div v-if="form.audit_ids.length === 0" class="review-empty">None selected</div>
                </div>
              </div>
              <div class="review-item">
                <div class="review-label">Safeguarding Cases:</div>
                <div class="review-value">
                  <div v-for="caseId in form.safeguarding_case_ids" :key="caseId" class="review-list-item">
                    {{ getCaseDescription(caseId) }}
                  </div>
                  <div v-if="form.safeguarding_case_ids.length === 0" class="review-empty">None selected</div>
                </div>
              </div>
            </div>
          </div>
        </template>
      </MultiStepForm>
    </div>
  </Layout>

  <!-- Modal for creating a new action plan -->
  <Modal :show="showCreateActionPlan" @close="showCreateActionPlan = false">
    <h2 class="modal-title">Create New Action Plan</h2>
    <form @submit.prevent="createActionPlan" class="modal-form">
      <div class="form-group">
        <label class="form-label">Name</label>
        <Input v-model="newActionPlan.name" placeholder="Enter action plan name" class="form-input" required />
      </div>
      <div class="form-group">
        <label class="form-label">Description</label>
        <textarea 
          v-model="newActionPlan.description" 
          placeholder="Enter description" 
          class="form-textarea"
          required
        ></textarea>
      </div>
      <div class="form-group">
        <label class="form-label">Due Date</label>
        <Input v-model="newActionPlan.due_date" type="date" class="form-input" required />
      </div>
      <div class="form-actions">
        <Button type="button" color="secondary" @click="showCreateActionPlan = false">Cancel</Button>
        <Button type="submit" color="primary">Create Action Plan</Button>
      </div>
    </form>
  </Modal>

  <!-- Modal for creating a new safeguarding case -->
  <Modal :show="showCreateSafeguardingCase" @close="showCreateSafeguardingCase = false">
    <h2 class="modal-title">Create New Safeguarding Case</h2>
    <form @submit.prevent="createSafeguardingCase" class="modal-form">
      <div class="form-group">
        <label class="form-label">Type</label>
        <select v-model="newSafeguardingCase.type" class="form-select" required>
          <option value="">Select Type</option>
          <option value="Child Protection">Child Protection</option>
          <option value="Vulnerable Adult">Vulnerable Adult</option>
          <option value="Staff Concern">Staff Concern</option>
        </select>
      </div>
      <div class="form-group">
        <label class="form-label">Description</label>
        <textarea 
          v-model="newSafeguardingCase.description" 
          placeholder="Enter description" 
          class="form-textarea"
          required
        ></textarea>
      </div>
      <div class="form-group">
        <label class="form-label">Priority</label>
        <select v-model="newSafeguardingCase.priority" class="form-select" required>
          <option value="">Select Priority</option>
          <option value="low">Low</option>
          <option value="medium">Medium</option>
          <option value="high">High</option>
          <option value="urgent">Urgent</option>
        </select>
      </div>
      <div class="form-actions">
        <Button type="button" color="secondary" @click="showCreateSafeguardingCase = false">Cancel</Button>
        <Button type="submit" color="primary">Create Safeguarding Case</Button>
      </div>
    </form>
  </Modal>
</template>

<style scoped>
/* Page Layout */
.breadcrumb {
  font-size: 0.75rem;
  color: #6B7280;
  margin-bottom: 0.5rem;
}

.breadcrumb-link {
  color: #6B7280;
  text-decoration: none;
  transition: color 0.2s ease;
}

.breadcrumb-link:hover {
  text-decoration: underline;
  color: var(--color-primary, #0070F3);
}

.breadcrumb-current {
  color: var(--color-primary, #0070F3);
  font-weight: 500;
}

.page-title {
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--color-text, #1F2937);
  margin-bottom: 1.5rem;
}

.form-container {
  max-width: 36rem;
  margin: 0 auto;
  background-color: white;
  border-radius: 0.75rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  padding: 1.5rem;
}

/* Section Styles */
.section-title {
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--color-text, #1F2937);
  margin-bottom: 1rem;
}

.section-description {
  color: #6B7280;
  font-size: 0.875rem;
  margin-bottom: 1.5rem;
}

/* Form Elements */
.form-group {
  margin-bottom: 1.5rem;
}

.form-label {
  display: block;
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--color-text, #1F2937);
  margin-bottom: 0.5rem;
}

.form-help-text {
  font-size: 0.75rem;
  color: #6B7280;
  margin-bottom: 0.5rem;
}

.form-select {
  width: 100%;
  padding: 0.625rem;
  border: 1px solid #E5E7EB;
  border-radius: 0.375rem;
  background-color: white;
  color: var(--color-text, #1F2937);
  font-size: 0.875rem;
  transition: border-color 0.15s ease;
  margin-bottom: 0.25rem;
}

.form-select:focus {
  outline: none;
  border-color: var(--color-primary, #0070F3);
  box-shadow: 0 0 0 2px rgba(0, 112, 243, 0.2);
}

.form-textarea {
  width: 100%;
  padding: 0.625rem;
  border: 1px solid #E5E7EB;
  border-radius: 0.375rem;
  background-color: white;
  color: var(--color-text, #1F2937);
  font-size: 0.875rem;
  transition: border-color 0.15s ease;
  margin-bottom: 0.25rem;
  min-height: 8rem;
  resize: vertical;
}

.form-textarea:focus {
  outline: none;
  border-color: var(--color-primary, #0070F3);
  box-shadow: 0 0 0 2px rgba(0, 112, 243, 0.2);
}

.form-error {
  color: var(--color-error, #EF4444);
  font-size: 0.75rem;
  margin-top: 0.25rem;
}

/* Checkbox Styles */
.checkbox-group {
  display: grid;
  gap: 0.5rem;
  margin-top: 0.5rem;
}

.checkbox-item {
  display: flex;
  align-items: center;
}

.checkbox-input {
  width: 1rem;
  height: 1rem;
  margin-right: 0.5rem;
  accent-color: var(--color-primary, #0070F3);
}

.checkbox-label {
  font-size: 0.875rem;
  color: var(--color-text, #1F2937);
}

.empty-state {
  font-size: 0.875rem;
  color: #6B7280;
  font-style: italic;
  padding: 0.5rem 0;
}

/* Review Section */
.review-container {
  background-color: #F9FAFB;
  border-radius: 0.5rem;
  padding: 1.25rem;
  border: 1px solid #E5E7EB;
}

.review-item {
  margin-bottom: 1.25rem;
}

.review-item:last-child {
  margin-bottom: 0;
}

.review-label {
  font-size: 0.75rem;
  color: #6B7280;
  margin-bottom: 0.25rem;
}

.review-value {
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--color-text, #1F2937);
}

.review-list-item {
  padding: 0.25rem 0;
}

.review-empty {
  font-size: 0.875rem;
  color: #6B7280;
  font-style: italic;
}
</style>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../supabase'
import Layout from '../components/Layout.vue'
import MultiStepForm from '../components/MultiStepForm.vue'
import Modal from '../components/Modal.vue'
import Button from '../components/Button.vue'
import Input from '../components/Input.vue'

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

// Modal visibility state
const showCreateActionPlan = ref(false)
const showCreateSafeguardingCase = ref(false)

// New item form data
const newActionPlan = ref({
  name: '',
  description: '',
  due_date: new Date().toISOString().split('T')[0],
  status: 'open'
})

const newSafeguardingCase = ref({
  type: '',
  description: '',
  priority: 'medium',
  status: 'open'
})

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
    .from('safeguarding_cases')
    .select('id, type, description')
    .order('created_at', { ascending: false })
  if (error) {
    console.error('Error fetching safeguarding cases:', error)
    return
  }
  safeguardingCases.value = data || []
}

async function createActionPlan() {
  try {
    // Validate form
    if (!newActionPlan.value.name || !newActionPlan.value.description || !newActionPlan.value.due_date) {
      alert('Please fill in all required fields')
      return
    }

    // Insert new action plan
    const { data, error } = await supabase
      .from('action_plans')
      .insert([
        {
          name: newActionPlan.value.name,
          description: newActionPlan.value.description,
          due_date: newActionPlan.value.due_date,
          status: newActionPlan.value.status,
          created_by: (await supabase.auth.getUser()).data.user?.id
        }
      ])
      .select()

    if (error) throw error

    // Add the new action plan to the form selection
    if (data && data.length > 0) {
      actionPlans.value.push(data[0])
      form.value.action_plan_ids.push(data[0].id)
    }

    // Reset form and close modal
    newActionPlan.value = {
      name: '',
      description: '',
      due_date: new Date().toISOString().split('T')[0],
      status: 'open'
    }
    showCreateActionPlan.value = false
  } catch (error) {
    console.error('Error creating action plan:', error)
    alert(`Error creating action plan: ${error.message || JSON.stringify(error)}`)
  }
}

async function createSafeguardingCase() {
  try {
    // Validate form
    if (!newSafeguardingCase.value.type || !newSafeguardingCase.value.description) {
      alert('Please fill in all required fields')
      return
    }

    // Insert new safeguarding case
    const { data, error } = await supabase
      .from('safeguarding_cases')
      .insert([
        {
          type: newSafeguardingCase.value.type,
          description: newSafeguardingCase.value.description,
          priority: newSafeguardingCase.value.priority,
          status: newSafeguardingCase.value.status,
          reported_by: (await supabase.auth.getUser()).data.user?.id
        }
      ])
      .select()

    if (error) throw error

    // Add the new safeguarding case to the form selection
    if (data && data.length > 0) {
      safeguardingCases.value.push(data[0])
      form.value.safeguarding_case_ids.push(data[0].id)
    }

    // Reset form and close modal
    newSafeguardingCase.value = {
      type: '',
      description: '',
      priority: 'medium',
      status: 'open'
    }
    showCreateSafeguardingCase.value = false
  } catch (error) {
    console.error('Error creating safeguarding case:', error)
    alert(`Error creating safeguarding case: ${error.message || JSON.stringify(error)}`)
  }
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

<style scoped>
/* Form container styling */
.form-container {
  background-color: #FFFFFF;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  padding: 2rem;
  margin-bottom: 2rem;
}

/* Section titles */
.section-title {
  color: #1F2937;
  font-size: 1.5rem;
  font-weight: 600;
  margin-bottom: 1.5rem;
  padding-bottom: 0.75rem;
  border-bottom: 1px solid #E5E7EB;
}

.section-description {
  color: #6B7280;
  margin-bottom: 1.5rem;
  font-size: 0.95rem;
}

/* Form groups */
.form-group {
  margin-bottom: 1.5rem;
}

.form-label {
  display: block;
  font-weight: 500;
  color: #1F2937;
  margin-bottom: 0.5rem;
  font-size: 0.95rem;
}

.form-help-text {
  color: #6B7280;
  font-size: 0.85rem;
  margin-bottom: 0.75rem;
}

/* Form controls */
.form-select {
  width: 100%;
  padding: 0.625rem 0.75rem;
  border: 1px solid #D1D5DB;
  border-radius: 0.375rem;
  background-color: white;
  color: #1F2937;
  transition: all 0.2s ease;
  font-size: 0.95rem;
  appearance: none;
  background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3e%3cpath stroke='%236b7280' stroke-linecap='round' stroke-linejoin='round' stroke-width='1.5' d='M6 8l4 4 4-4'/%3e%3c/svg%3e");
  background-position: right 0.5rem center;
  background-repeat: no-repeat;
  background-size: 1.5em 1.5em;
  padding-right: 2.5rem;
}

.form-select:focus {
  outline: none;
  border-color: #0070F3;
  box-shadow: 0 0 0 3px rgba(0, 112, 243, 0.15);
}

.form-textarea {
  width: 100%;
  padding: 0.75rem;
  min-height: 120px;
  border: 1px solid #D1D5DB;
  border-radius: 0.375rem;
  background-color: white;
  color: #1F2937;
  transition: all 0.2s ease;
  font-size: 0.95rem;
  resize: vertical;
}

.form-textarea:focus {
  outline: none;
  border-color: #0070F3;
  box-shadow: 0 0 0 3px rgba(0, 112, 243, 0.15);
}

/* Checkbox styling */
.checkbox-group {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  margin-top: 0.5rem;
}

.checkbox-item {
  display: flex;
  align-items: center;
}

.checkbox-input {
  height: 1.125rem;
  width: 1.125rem;
  border-radius: 0.25rem;
  border: 1px solid #D1D5DB;
  cursor: pointer;
  accent-color: #0070F3;
}

.checkbox-label {
  margin-left: 0.5rem;
  font-size: 0.95rem;
  color: #1F2937;
  cursor: pointer;
}

/* Error states */
.form-error {
  color: #EF4444;
  font-size: 0.85rem;
  margin-top: 0.375rem;
}

.empty-state {
  color: #6B7280;
  font-size: 0.9rem;
  font-style: italic;
  padding: 0.75rem 0;
}

/* Review section */
.review-container {
  background-color: #F9FAFB;
  border-radius: 0.5rem;
  padding: 1.5rem;
}

.review-item {
  display: flex;
  margin-bottom: 1.25rem;
  border-bottom: 1px solid #E5E7EB;
  padding-bottom: 1rem;
}

.review-item:last-child {
  border-bottom: none;
  margin-bottom: 0;
  padding-bottom: 0;
}

.review-label {
  width: 35%;
  font-weight: 600;
  color: #4B5563;
  padding-right: 1rem;
}

.review-value {
  width: 65%;
  color: #1F2937;
}

.review-list-item {
  margin-bottom: 0.5rem;
  padding-left: 0.75rem;
  border-left: 2px solid #0070F3;
}

.review-empty {
  color: #6B7280;
  font-style: italic;
}

/* Form actions */
.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
  margin-top: 1.5rem;
}

/* Modal styling */
.modal-title {
  font-size: 1.25rem;
  font-weight: 600;
  color: #1F2937;
  margin-bottom: 1.25rem;
  padding-bottom: 0.75rem;
  border-bottom: 1px solid #E5E7EB;
}

.modal-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

/* Flex utilities */
.flex {
  display: flex;
}

.justify-between {
  justify-content: space-between;
}

.items-center {
  align-items: center;
}

.mb-2 {
  margin-bottom: 0.5rem;
}

.mb-0 {
  margin-bottom: 0;
}

/* Responsive adjustments */
@media (max-width: 640px) {
  .form-container {
    padding: 1.25rem;
  }
  
  .review-item {
    flex-direction: column;
  }
  
  .review-label,
  .review-value {
    width: 100%;
  }
  
  .review-label {
    margin-bottom: 0.375rem;
  }
  
  .form-actions {
    flex-direction: column;
  }
}
</style>
