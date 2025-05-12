<template>
  <div class="assignment-form">
    <h2 class="text-xl font-semibold mb-4 text-slate-800">Assign Audit</h2>
    
    <form @submit.prevent="handleSubmit" aria-label="Assign Audit">
      <div class="space-y-6">
        <!-- Template Selection -->
        <div>
          <label class="block text-sm font-medium text-[#1F2937] mb-1" for="template-select">
            Template
          </label>
          <select
            id="template-select"
            v-model="form.template_id"
            required
            aria-label="Audit Template"
            class="w-full px-3 py-2 border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#0070F3] font-sans"
          >
            <option v-for="template in templates" :key="template.id" :value="template.id">
              {{ template.title }} ({{ template.frequency }})
            </option>
          </select>
        </div>
        <!-- Assign To -->
        <div>
          <label class="block text-sm font-medium text-[#1F2937] mb-1" for="user-select">
            Assign To
          </label>
          <select
            id="user-select"
            v-model="form.assigned_to"
            required
            aria-label="Assign To User"
            class="w-full px-3 py-2 border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#0070F3] font-sans"
          >
            <option v-for="user in users" :key="user.id" :value="user.id">
              {{ user.email }}
            </option>
          </select>
        </div>
        <!-- Due Date -->
        <div>
          <label class="block text-sm font-medium text-[#1F2937] mb-1" for="due-date-input">
            Due Date
          </label>
          <input
            id="due-date-input"
            v-model="form.due_date"
            type="date"
            required
            aria-label="Due Date"
            class="w-full px-3 py-2 border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#0070F3] font-sans"
          />
        </div>
        <!-- Form Actions -->
        <div class="flex justify-end space-x-3 pt-4">
          <button
            type="button"
            @click="$emit('cancel')"
            class="px-4 py-2 border border-slate-300 rounded-md text-[#1F2937] hover:bg-slate-50 font-sans"
            aria-label="Cancel Assignment"
          >
            Cancel
          </button>
          <button
            type="submit"
            class="px-4 py-2 bg-[#0070F3] text-white rounded-md hover:bg-blue-700 font-sans"
            aria-label="Assign Audit"
          >
            Assign
          </button>
        </div>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '../../supabase'

const emit = defineEmits(['submit', 'cancel'])

const form = ref({
  template_id: '',
  assigned_to: '',
  due_date: ''
})

const users = ref<any[]>([])
const templates = ref<any[]>([])

// Fetch users and templates
async function fetchData() {
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
  
  // Set default template if available
  if (templates.value.length > 0) {
    form.value.template_id = templates.value[0].id
  }
  
  // Set default user if available
  if (users.value.length > 0) {
    form.value.assigned_to = users.value[0].id
  }
  
  // Set default due date (tomorrow)
  const tomorrow = new Date()
  tomorrow.setDate(tomorrow.getDate() + 1)
  form.value.due_date = tomorrow.toISOString().split('T')[0]
}

function handleSubmit() {
  emit('submit', {
    template_id: form.value.template_id,
    assigned_to: form.value.assigned_to,
    assigned_by: supabase.auth.user()?.id,
    due_date: form.value.due_date,
    status: 'pending'
  })
}

// Initialize component
onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.assignment-form {
  @apply bg-white p-6 rounded-lg shadow-sm;
}
</style>
