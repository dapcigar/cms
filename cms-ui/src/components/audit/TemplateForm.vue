<template>
  <div class="template-form font-sans">
    <h2 class="text-xl font-semibold mb-4 text-[#1F2937]">
      {{ editing ? 'Edit Template' : 'Create Template' }}
    </h2>
    <form @submit.prevent="handleSubmit" role="form" aria-label="Audit Template Form" novalidate>
      <div v-if="error" class="mb-4 text-[#EF4444] text-sm" aria-live="polite">{{ error }}</div>
      <div class="space-y-6">
        <div>
          <label class="block text-sm font-medium text-[#1F2937] mb-1">Title</label>
          <input
            v-model="form.title"
            type="text"
            required
            aria-label="Template Title"
            :aria-invalid="!form.title"
            class="w-full px-3 py-3 min-h-[44px] border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#0070F3] font-sans transition-all duration-200 placeholder:font-sans placeholder:text-[#94A3B8]"
            placeholder="Enter template title"
            autocomplete="off"
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-[#1F2937] mb-1">Frequency</label>
          <select
            v-model="form.frequency"
            required
            aria-label="Audit Frequency"
            class="w-full px-3 py-3 min-h-[44px] border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#0070F3] font-sans transition-all duration-200"
          >
            <option value="daily">Daily</option>
            <option value="weekly">Weekly</option>
            <option value="monthly">Monthly</option>
          </select>
        </div>
        <div class="flex justify-end space-x-3 pt-4">
          <button
            type="button"
            @click="$emit('cancel')"
            aria-label="Cancel"
            class="px-4 py-3 min-h-[44px] border border-slate-300 rounded-md text-[#1F2937] hover:bg-slate-50 font-sans transition-all duration-200"
          >
            Cancel
          </button>
          <button
            type="submit"
            :aria-label="editing ? 'Update Template' : 'Create Template'"
            class="px-4 py-3 min-h-[44px] bg-[#0070F3] text-white rounded-md hover:bg-[#005CC5] font-sans transition-all duration-200 focus:ring-2 focus:ring-[#0070F3] focus:ring-offset-2"
          >
            {{ editing ? 'Update' : 'Create' }}
          </button>
        </div>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
const props = defineProps({
  editing: {
    type: Boolean,
    default: false
  },
  template: {
    type: Object,
    default: null
  }
})
const emit = defineEmits(['submit', 'cancel'])
const form = ref({
  id: null,
  title: '',
  frequency: 'daily',
})
const error = ref('')
watch(
  () => props.template,
  (val) => {
    if (props.editing && val) {
      form.value.id = val.id
      form.value.title = val.title
      form.value.frequency = val.frequency
    } else {
      form.value.id = null
      form.value.title = ''
      form.value.frequency = 'daily'
    }
  },
  { immediate: true }
)
function handleSubmit() {
  error.value = ''
  if (!form.value.title) {
    error.value = 'Template title is required.'
    return
  }
  emit('submit', {
    id: form.value.id,
    title: form.value.title,
    frequency: form.value.frequency
  })
}
</script>

<style scoped>
.template-form {
  @apply bg-white p-6 rounded-lg shadow-sm;
  font-family: 'Inter', 'Open Sans', sans-serif;
}
</style>
