<template>
  <div class="assignment-form">
    <h2 class="text-xl font-semibold mb-4 text-slate-800">Assign Audit</h2>
    
    <form @submit.prevent="handleSubmit">
      <div class="space-y-4">
        <!-- Template Selection -->
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1">
            Template
          </label>
          <select
            v-model="form.template_id"
            required
            class="w-full px-3 py-2 border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option v-for="template in templates" :key="template.id" :value="template.id">
              {{ template.title }} ({{ template.frequency }})
            </option>
          </select>
        </div>

        <!-- Assign To -->
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1">
            Assign To
          </label>
          <select
            v-model="form.assigned_to"
            required
            class="w-full px-3 py-2 border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option v-for="user in users" :key="user.id" :value="user.id">
              {{ user.email }}
            </option>
          </select>
        </div>

        <!-- Due Date -->
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1">
            Due Date
          </label>
          <input
            v-model="form.due_date"
            type="date"
            required
            class="w-full px-3 py-2 border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <!-- Form Actions -->
        <div class="flex justify-end space-x-3 pt-4">
          <button
            type="button"
            @click="$emit('cancel')"
            class="px-4 py-2 border border-slate-300 rounded-md text-slate-700 hover:bg-slate-50"
          >
            Cancel
          </button>
          <button
            type="submit"
            class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
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
