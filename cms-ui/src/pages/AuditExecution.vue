<template>
  <div class="audit-execution">
    <!-- Header with status -->
    <div class="flex justify-between items-center mb-6">
      <div>
        <h1 class="text-2xl font-bold text-slate-800">{{ assignment.template.title }}</h1>
        <div class="text-sm text-slate-600">
          Due: {{ formatDate(assignment.due_date) }}
          <span 
            class="ml-2 px-2 py-1 text-xs rounded-full"
            :class="statusClasses"
          >
            {{ formattedStatus }}
          </span>
        </div>
      </div>
      
      <div v-if="!isComplete" class="flex space-x-3">
        <button 
          @click="saveDraft"
          class="px-4 py-2 border border-slate-300 rounded-md text-slate-700 hover:bg-slate-50"
        >
          Save Draft
        </button>
        <button 
          @click="completeAudit"
          class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
        >
          Complete Audit
        </button>
      </div>
      <div v-else class="text-green-600 font-medium">
        Audit Completed on {{ formatDate(assignment.completed_at) }}
      </div>
    </div>
    
    <!-- Questions List -->
    <div class="space-y-4">
      <div 
        v-for="(question, index) in questions" 
        :key="question.id"
        class="p-4 border border-slate-200 rounded-lg"
      >
        <h3 class="font-medium text-slate-800 mb-2">
          {{ index + 1 }}. {{ question.question_text }} 
          <span class="text-sm text-slate-500">(Max score: {{ question.max_score }})</span>
        </h3>
        
        <!-- Score Input -->
        <div class="mb-3">
          <label class="block text-sm font-medium text-slate-700 mb-1">Score</label>
          <input
            v-model.number="responses[question.id].score"
            type="number"
            min="0"
            :max="question.max_score"
            required
            :disabled="isComplete"
            class="w-24 px-3 py-2 border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>
        
        <!-- Notes -->
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1">Notes</label>
          <textarea
            v-model="responses[question.id].notes"
            :disabled="isComplete"
            class="w-full px-3 py-2 border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            rows="3"
          ></textarea>
        </div>
      </div>
    </div>
    
    <!-- Summary Section -->
    <div v-if="questions.length > 0" class="mt-8 p-4 bg-slate-50 rounded-lg">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <h3 class="text-sm font-medium text-slate-700">Total Possible Score</h3>
          <p class="text-xl font-semibold text-slate-800">{{ totalPossibleScore }}</p>
        </div>
        <div>
          <h3 class="text-sm font-medium text-slate-700">Your Score</h3>
          <p class="text-xl font-semibold text-slate-800">{{ currentScore }}</p>
        </div>
        <div>
          <h3 class="text-sm font-medium text-slate-700">Percentage</h3>
          <p 
            class="text-xl font-semibold"
            :class="{
              'text-red-600': percentage < 70,
              'text-yellow-600': percentage >= 70 && percentage < 85,
              'text-green-600': percentage >= 85
            }"
          >
            {{ percentage }}%
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { supabase } from '../supabase'

const route = useRoute()
const assignmentId = route.params.id

const assignment = ref<any>({ template: {} })
const questions = ref<any[]>([])
const responses = ref<Record<string, { score: number; notes: string }>>({})

const isComplete = computed(() => assignment.value.status === 'completed')

const statusClasses = computed(() => {
  return {
    'bg-blue-100 text-blue-800': assignment.value.status === 'pending',
    'bg-yellow-100 text-yellow-800': assignment.value.status === 'in_progress',
    'bg-green-100 text-green-800': assignment.value.status === 'completed',
    'bg-red-100 text-red-800': assignment.value.status === 'overdue'
  }
})

const formattedStatus = computed(() => {
  return {
    'pending': 'Pending',
    'in_progress': 'In Progress',
    'completed': 'Completed',
    'overdue': 'Overdue'
  }[assignment.value.status]
})

const totalPossibleScore = computed(() => {
  return questions.value.reduce((sum, q) => sum + q.max_score, 0)
})

const currentScore = computed(() => {
  return Object.values(responses.value).reduce((sum, r) => sum + (r.score || 0), 0)
})

const percentage = computed(() => {
  return Math.round((currentScore.value / totalPossibleScore.value) * 100)
})

// Fetch assignment and questions
async function fetchData() {
  // Get assignment
  const { data: assignmentData, error: assignmentError } = await supabase
    .from('audit_assignments')
    .select(`
      *,
      template:audit_templates(*)
    `)
    .eq('id', assignmentId)
    .single()
    
  if (assignmentError) {
    console.error('Error fetching assignment:', assignmentError)
    return
  }
  
  assignment.value = assignmentData
  
  // Get questions
  const { data: questionsData, error: questionsError } = await supabase
    .from('audit_questions')
    .select('*')
    .eq('template_id', assignment.value.template.id)
    .order('question_order', { ascending: true })
    
  if (questionsError) {
    console.error('Error fetching questions:', questionsError)
    return
  }
  
  questions.value = questionsData
  
  // Initialize responses
  questions.value.forEach(q => {
    responses.value[q.id] = {
      score: 0,
      notes: ''
    }
  })
  
  // Load existing responses if any
  if (assignment.value.status !== 'pending') {
    await loadResponses()
  }
}

// Load existing responses
async function loadResponses() {
  const { data, error } = await supabase
    .from('audit_responses')
    .select('*')
    .eq('assignment_id', assignmentId)
    
  if (error) {
    console.error('Error loading responses:', error)
    return
  }
  
  data.forEach(r => {
    if (responses.value[r.question_id]) {
      responses.value[r.question_id] = {
        score: r.score,
        notes: r.notes || ''
      }
    }
  })
}

// Save draft (update status to in_progress)
async function saveDraft() {
  // First save all responses
  await saveResponses()
  
  // Update assignment status
  const { error } = await supabase
    .from('audit_assignments')
    .update({ 
      status: 'in_progress',
      updated_at: new Date().toISOString() 
    })
    .eq('id', assignmentId)
    
  if (error) {
    console.error('Error saving draft:', error)
    return
  }
  
  // Refresh assignment
  await fetchData()
}

// Complete the audit
async function completeAudit() {
  // First save all responses
  await saveResponses()
  
  // Update assignment status
  const { error } = await supabase
    .from('audit_assignments')
    .update({ 
      status: 'completed',
      updated_at: new Date().toISOString(),
      completed_at: new Date().toISOString()
    })
    .eq('id', assignmentId)
    
  if (error) {
    console.error('Error completing audit:', error)
    return
  }
  
  // Refresh assignment
  await fetchData()
}

// Save all responses to database
async function saveResponses() {
  const responseRecords = Object.entries(responses.value).map(([questionId, response]) => ({
    assignment_id: assignmentId,
    question_id: questionId,
    score: response.score,
    notes: response.notes
  }))
  
  // Delete existing responses
  await supabase
    .from('audit_responses')
    .delete()
    .eq('assignment_id', assignmentId)
    
  // Insert new responses
  const { error } = await supabase
    .from('audit_responses')
    .insert(responseRecords)
    
  if (error) {
    console.error('Error saving responses:', error)
    return
  }
}

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString()
}

// Initialize component
onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.audit-execution {
  @apply p-6;
}
</style>
