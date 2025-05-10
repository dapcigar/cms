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
              <p class="form-help-text">Select the users who will be responsible for this incident</p>
              <div class="checkbox-group">
                <div v-for="user in users" :key="user.id" class="checkbox-item">
                  <input 
                    type="checkbox" 
                    :id="user.id" 
                    :value="user.id" 
                    v-model="form.assigned_users"
                    class="checkbox-input"
                  >
                  <label :for="user.id" class="checkbox-label">{{ user.email }}</label>
                </div>
              </div>
              <div v-if="errors.assigned_users" class="form-error">{{ errors.assigned_users }}</div>
            </div>
          </div>

          <div v-else-if="step === 2">
            <h2 class="section-title">Related Items</h2>
            <p class="section-description">Link this incident to relevant action plans, audits, and safeguarding cases</p>
            
            <div class="form-group">
              <label class="form-label">Action Plans</label>
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
              <label class="form-label">Safeguarding Cases</label>
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
