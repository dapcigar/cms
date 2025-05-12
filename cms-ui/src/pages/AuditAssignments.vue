<template>
  <div class="audit-assignments">
    <!-- Header with create button -->
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-2xl font-bold text-slate-800">Audit Assignments</h1>
      <button 
        @click="showAssignmentForm = true"
        class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md"
      >
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
    <div class="mb-6 p-4 bg-slate-50 rounded-lg">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1">Status</label>
          <select 
            v-model="filters.status" 
            class="w-full px-3 py-2 border border-slate-300 rounded-md"
          >
            <option value="all">All</option>
            <option value="pending">Pending</option>
            <option value="in_progress">In Progress</option>
            <option value="completed">Completed</option>
            <option value="overdue">Overdue</option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1">User</label>
          <select 
            v-model="filters.user" 
            class="w-full px-3 py-2 border border-slate-300 rounded-md"
          >
            <option value="all">All Users</option>
            <option v-for="user in users" :key="user.id" :value="user.id">
              {{ user.email }}
            </option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1">Template</label>
          <select 
            v-model="filters.template" 
            class="w-full px-3 py-2 border border-slate-300 rounded-md"
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
    <div class="space-y-4">
      <AssignmentCard 
        v-for="assignment in filteredAssignments" 
        :key="assignment.id"
        :assignment="assignment"
        @complete="markAssignmentComplete"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../supabase'
import Modal from '../components/Modal.vue'
import AssignmentForm from '../components/audit/AssignmentForm.vue'
import AssignmentCard from '../components/audit/AssignmentCard.vue'

const showAssignmentForm = ref(false)
const assignments = ref<any[]>([])
const users = ref<any[]>([])
const templates = ref<any[]>([])

const filters = ref({
  status: 'all',
  user: 'all',
  template: 'all'
})

// Fetch data from Supabase
async function fetchData() {
  // Get assignments with related data
  const { data: assignmentsData, error: assignmentsError } = await supabase
    .from('audit_assignments')
    .select(`
      *,
      assigned_to:profiles!audit_assignments_assigned_to_fkey(*),
      assigned_by:profiles!audit_assignments_assigned_by_fkey(*),
      template:audit_templates!audit_assignments_template_id_fkey(*)
    `)
    .order('due_date', { ascending: true })
    
  if (assignmentsError) {
    console.error('Error fetching assignments:', assignmentsError)
    return
  }
  
  assignments.value = assignmentsData
  
  // Get users
  const { data: usersData, error: usersError } = await supabase
    .from('profiles')
    .select('*')
    
  if (usersError) {
    console.error('Error fetching users:', usersError)
    return
  }
  
  users.value = usersData
  
  // Get templates
  const { data: templatesData, error: templatesError } = await supabase
    .from('audit_templates')
    .select('*')
    
  if (templatesError) {
    console.error('Error fetching templates:', templatesError)
    return
  }
  
  templates.value = templatesData
}

// Filter assignments based on selected filters
const filteredAssignments = computed(() => {
  return assignments.value.filter(assignment => {
    const statusMatch = filters.value.status === 'all' || assignment.status === filters.value.status
    const userMatch = filters.value.user === 'all' || assignment.assigned_to.id === filters.value.user
    const templateMatch = filters.value.template === 'all' || assignment.template.id === filters.value.template
    
    return statusMatch && userMatch && templateMatch
  })
})

// Create new assignment
async function createAssignment(assignmentData: any) {
  const { data, error } = await supabase
    .from('audit_assignments')
    .insert([assignmentData])
    .select()
    
  if (error) {
    console.error('Error creating assignment:', error)
    return
  }
  
  // Refresh data
  await fetchData()
  showAssignmentForm.value = false
}

// Mark assignment as complete
async function markAssignmentComplete(assignmentId: string) {
  const { error } = await supabase
    .from('audit_assignments')
    .update({ status: 'completed', updated_at: new Date().toISOString() })
    .eq('id', assignmentId)
    
  if (error) {
    console.error('Error updating assignment:', error)
    return
  }
  
  // Refresh data
  await fetchData()
}

// Initialize component
onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.audit-assignments {
  @apply p-6;
}
</style>
