<template>
  <div class="template-form">
    <h2 class="text-xl font-semibold mb-4 text-slate-800">
      {{ editing ? 'Edit Template' : 'Create Template' }}
    </h2>
    
    <form @submit.prevent="handleSubmit">
      <div class="space-y-4">
        <!-- Title Input -->
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1">
            Template Title
          </label>
          <input
            v-model="form.title"
            type="text"
            required
            class="w-full px-3 py-2 border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <!-- Frequency Select -->
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1">
            Frequency
          </label>
          <select
            v-model="form.frequency"
            required
            class="w-full px-3 py-2 border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="daily">Daily</option>
            <option value="weekly">Weekly</option>
            <option value="monthly">Monthly</option>
          </select>
        </div>

        <!-- Questions Section -->
        <div>
          <div class="flex justify-between items-center mb-1">
            <label class="block text-sm font-medium text-slate-700">
              Questions
            </label>
            <button
              type="button"
              @click="addQuestion"
              class="text-sm text-blue-600 hover:text-blue-800"
            >
              + Add Question
            </button>
          </div>
          
          <div v-for="(question, index) in form.questions" :key="index" class="mb-3 p-3 border border-slate-200 rounded-md">
            <div class="flex justify-between mb-2">
              <span class="text-sm font-medium text-slate-700">Question {{ index + 1 }}</span>
              <button
                type="button"
                @click="removeQuestion(index)"
                class="text-sm text-red-600 hover:text-red-800"
              >
                Remove
              </button>
            </div>
            
            <!-- Question Text -->
            <input
              v-model="question.text"
              type="text"
              placeholder="Enter question text"
              required
              class="w-full px-2 py-1 mb-2 border border-slate-300 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-500"
            />
            
            <!-- Max Score -->
            <div>
              <label class="block text-xs text-slate-600 mb-1">Max Score</label>
              <input
                v-model.number="question.maxScore"
                type="number"
                min="1"
                required
                class="w-full px-2 py-1 border border-slate-300 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-500"
              />
            </div>
          </div>
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
            {{ editing ? 'Update' : 'Create' }}
          </button>
        </div>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

defineProps({
  editing: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['submit', 'cancel'])

const form = ref({
  title: '',
  frequency: 'daily',
  questions: [
    { text: '', maxScore: 1 }
  ]
})

function addQuestion() {
  form.value.questions.push({ text: '', maxScore: 1 })
}

function removeQuestion(index: number) {
  form.value.questions.splice(index, 1)
}

function handleSubmit() {
  emit('submit', form.value)
}
</script>

<style scoped>
.template-form {
  @apply bg-white p-6 rounded-lg shadow-sm;
}
</style>
