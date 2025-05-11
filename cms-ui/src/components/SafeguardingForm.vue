<template>
  <div class="modal-container bg-white rounded-lg shadow-lg p-6 max-w-md mx-auto relative">
    <button 
      class="modal-close absolute top-4 right-4 text-gray-500 hover:text-gray-700 text-2xl"
      @click="$emit('close')"
    >
      ×
    </button>
    
    <h2 class="font-heading text-2xl mb-6 text-[#1F2937]">Create Safeguarding Case</h2>
    
    <form @submit.prevent="handleSubmit" class="space-y-4">
      <!-- Type -->
      <div>
        <label class="block text-sm font-medium text-[#1F2937] mb-1">Type*</label>
        <input 
          type="text" 
          v-model="form.type"
          placeholder="Enter case type"
          required
          class="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#0070F3] focus:border-transparent"
        >
      </div>

      <!-- Description -->
      <div>
        <label class="block text-sm font-medium text-[#1F2937] mb-1">Description*</label>
        <textarea
          v-model="form.description"
          placeholder="Enter case description"
          required
          class="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#0070F3] focus:border-transparent min-h-[100px]"
        ></textarea>
      </div>

      <!-- Date Occurred -->
      <div>
        <label class="block text-sm font-medium text-[#1F2937] mb-1">Date Occurred</label>
        <input 
          type="date" 
          v-model="form.dateOccurred"
          class="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#0070F3] focus:border-transparent"
        >
      </div>

      <!-- Status -->
      <div>
        <label class="block text-sm font-medium text-[#1F2937] mb-1">Status*</label>
        <select 
          v-model="form.status"
          required
          class="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#0070F3] focus:border-transparent appearance-none bg-[url('data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiAjdjE0MTQxNCIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiPjxwb2x5bGluZSBwb2ludHM9IjYgOSAxMiAxNSAxOCA5Ij48L3BvbHlsaW5lPjwvc3ZnPg==')] bg-no-repeat bg-[center_right_1rem]"
        >
          <option value="open">Open</option>
          <option value="resolved">Resolved</option>
        </select>
      </div>

      <!-- Priority -->
      <div>
        <label class="block text-sm font-medium text-[#1F2937] mb-1">Priority</label>
        <div class="flex gap-2">
          <label class="inline-flex items-center">
            <input type="radio" v-model="form.priority" value="high" class="text-[#EF4444] focus:ring-[#EF4444] mr-1">
            <span class="text-sm">High</span>
          </label>
          <label class="inline-flex items-center">
            <input type="radio" v-model="form.priority" value="medium" class="text-[#F59E0B] focus:ring-[#F59E0B] mr-1">
            <span class="text-sm">Medium</span>
          </label>
          <label class="inline-flex items-center">
            <input type="radio" v-model="form.priority" value="low" class="text-[#10B981] focus:ring-[#10B981] mr-1">
            <span class="text-sm">Low</span>
          </label>
        </div>
      </div>

      <!-- Assigned Users -->
      <div>
        <label class="block text-sm font-medium text-[#1F2937] mb-1">Assigned Users</label>
        <select 
          v-model="form.assignedUsers"
          multiple
          class="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#0070F3] focus:border-transparent min-h-[100px]"
        >
          <option 
            v-for="user in users" 
            :key="user.id" 
            :value="user.id"
          >
            {{ user.name || user.email }}
          </option>
        </select>
      </div>

      <!-- Error Message -->
      <div v-if="error" class="p-3 bg-[#FF7A59]/10 text-[#FF7A59] rounded-md text-sm">
        {{ error }}
      </div>

      <!-- Submit Button -->
      <Button 
        type="submit" 
        color="primary" 
        class="w-full mt-4"
        :disabled="loading"
      >
        <span v-if="!loading">Create Case</span>
        <span v-else class="flex items-center justify-center gap-2">
          <svg class="animate-spin h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          Creating...
        </span>
      </Button>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import Button from './Button.vue'

const props = defineProps({
  users: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['submit', 'close'])

const form = ref({
  type: '',
  description: '',
  dateOccurred: new Date().toISOString().split('T')[0],
  status: 'open',
  priority: 'medium',
  assignedUsers: []
})

const loading = ref(false)
const error = ref('')

async function handleSubmit() {
  try {
    loading.value = true
    error.value = ''
    
    if (!form.value.type || !form.value.description) {
      throw new Error('Type and description are required')
    }
    
    emit('submit', {
      ...form.value,
      assigned_users: form.value.assignedUsers
    })
    
  } catch (err) {
    error.value = err.message || 'Failed to create case'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.modal-container {
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
}

input[type="date"]::-webkit-calendar-picker-indicator {
  filter: invert(0.5);
}
</style>
