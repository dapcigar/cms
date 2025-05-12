<template>
  <div class="audit-assignments">
    <div class="assignments-header">
      <h1>Audit Assignments</h1>
      <button @click="showAssignmentForm = true" class="primary-btn">
        <span class="material-icons">add</span>
        New Assignment
      </button>
    </div>
    <!-- Header with create button -->
    <div class="flex justify-between items-center mb-8">
      <h1 class="text-2xl font-semibold text-gray-800">Audit Assignments</h1>
      <button 
        @click="showAssignmentForm = true"
        class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md flex items-center gap-2 transition-colors"
      >
        <span class="material-icons">add</span>
        New Assignment
      </button>
    </div>

    <!-- Assignment creation modal -->
    <Modal v-model="showAssignmentForm">
      <AssignmentForm 
        @submit="createAssignment" 
        @cancel="showAssignmentForm = false" 
      />
    </Modal>

    <!-- Filter controls -->
    <div class="filters-bar">

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Status</label>
          <select 
            v-model="filters.status" 
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 transition-colors"
          >
            <option value="all">All</option>
            <option value="pending">Pending</option>
            <option value="in_progress">In Progress</option>
            <option value="completed">Completed</option>
            <option value="overdue">Overdue</option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">User</label>
          <select 
            v-model="filters.user" 
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 transition-colors"
          >
            <option value="all">All Users</option>
            <option v-for="user in users" :key="user.id" :value="user.id">
              {{ user.email }}
            </option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Template</label>
          <select 
            v-model="filters.template" 
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 transition-colors"
          >
            <option value="all">All Templates</option>
            <option v-for="template in templates" :key="template.id" :value="template.id">
              {{ template.title }}
            </option>
          </select>
        </div>
      </div>
    </div>

    <!-- Assignments list -->
    <div v-if="filteredAssignments.length > 0" class="assignments-list">
      <div v-for="assignment in filteredAssignments" :key="assignment.id" class="assignment-card">
        <div class="assignment-card-header">
          <h3>{{ getTemplateTitle(assignment.template_id) }}</h3>
          <div class="assignment-card-actions">
            <span :class="[getStatusBadge(assignment.status), 'status-badge']">
              {{ assignment.status.charAt(0).toUpperCase() + assignment.status.slice(1) }}
            </span>
            <button class="edit-btn"><span class="material-icons">edit</span></button>
          </div>
        </div>
        <div class="assignment-card-details">
          <p><span class="material-icons">person</span> {{ getUserEmail(assignment.assigned_to) }}</p>
          <p><span class="material-icons">calendar_today</span> {{ new Date(assignment.due_date).toLocaleDateString() }}</p>
        </div>
      </div>
    </div>
    <p v-else class="no-results">
      No assignments found matching your filters.
    </p>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../supabase'
import AssignmentForm from '../components/audit/AssignmentForm.vue'
import Modal from '../components/Modal.vue'

const showAssignmentForm = ref(false)
const assignments = ref<any[]>([])
const templates = ref<any[]>([])
const users = ref<any[]>([])

const filters = ref({
  status: 'all',
  user: 'all',
  template: 'all'
})

// Computed property for filtered assignments
const filteredAssignments = computed(() => {
  return assignments.value.filter(assignment => {
    if (filters.value.status !== 'all' && assignment.status !== filters.value.status) {
      return false
    }
    if (filters.value.user !== 'all' && assignment.assigned_to !== filters.value.user) {
      return false
    }
    if (filters.value.template !== 'all' && assignment.template_id !== filters.value.template) {
      return false
    }
    return true
  })
})

// Helper methods
const getStatusBadge = (status) => {
  switch(status) {
    case 'pending': return 'bg-gray-100 text-gray-800'
    case 'in_progress': return 'bg-blue-100 text-blue-800'
    case 'completed': return 'bg-green-100 text-green-800'
    case 'overdue': return 'bg-red-100 text-red-800'
    default: return 'bg-gray-100 text-gray-800'
  }
}

const getTemplateTitle = (id) => {
  const template = templates.value.find(t => t.id === id)
  return template ? template.title : 'Unknown Template'
}

const getUserEmail = (id) => {
  const user = users.value.find(u => u.id === id)
  return user ? user.email : 'Unknown User'
}

// Fetch data
async function fetchAssignments() {
  try {
    const { data, error } = await supabase
      .from('audit_assignments')
      .select('*')
    if (error) throw error
    assignments.value = data || []
  } catch (error) {
    console.error('Error fetching assignments:', error)
  }
}

async function fetchTemplates() {
  try {
    const { data, error } = await supabase
      .from('audit_templates')
      .select('*')
    if (error) throw error
    templates.value = data || []
  } catch (error) {
    console.error('Error fetching templates:', error)
  }
}

async function fetchUsers() {
  try {
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
    if (error) throw error
    users.value = data || []
  } catch (error) {
    console.error('Error fetching users:', error)
  }
}

async function createAssignment(assignmentData) {
  try {
    const { data, error } = await supabase
      .from('audit_assignments')
      .insert([assignmentData])
      .select()
    if (error) throw error
    assignments.value.unshift(data[0])
    showAssignmentForm.value = false
  } catch (error) {
    console.error('Error creating assignment:', error)
  }
}

// Initialize component
onMounted(() => {
  fetchAssignments()
  fetchTemplates()
  fetchUsers()
})
</script>

<style scoped>
/* Add custom styles if needed */
</style>
