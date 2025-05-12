<template>
  <div class="audit-templates bg-[#F9FAFB] min-h-screen">
    <div class="flex justify-between items-center mb-8">
      <h1 class="text-2xl font-semibold text-[#1F2937]">Audit Templates</h1>
      <button 
        @click="showCreateModal = true"
        class="bg-[#0070F3] hover:bg-[#005CC5] text-white px-4 py-2 rounded-md flex items-center gap-2 transition-colors"
      >
        <span class="material-icons">add</span>
        New Template
      </button>
    </div>

    <div class="container mx-auto px-4 py-6">
      <div v-if="templates.length === 0" class="text-center py-12">
        <p class="text-[#6B7280] mb-4">
          No templates found. Create your first audit template.
        </p>
      </div>
      <div v-else class="template-grid grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <TemplateCard
          v-for="template in templates"
          :key="template.id"
          :template="template"
          @edit="openEditModal(template)"
          @delete="deleteTemplate(template.id)"
          @detail="openDetail(template)"
        />
      </div>
    </div>

    <!-- Create/Edit Modal -->
    <Modal :show="showCreateModal" @close="showCreateModal = false">
      <div class="p-6">
        <h2 class="text-xl font-semibold mb-4 text-[#1F2937]">
          {{ editingTemplate ? 'Edit Template' : 'Create Template' }}
        </h2>
        <TemplateForm 
          :template="editingTemplate" 
          @submit="handleSubmit" 
          @cancel="showCreateModal = false" 
        />
      </div>
    </Modal>

    <!-- Template Detail Drawer/Modal (Tabbed) -->
    <transition name="slide">
      <div v-if="showDetail" class="fixed inset-0 bg-black/20 flex items-center justify-end z-50">
        <div class="w-full max-w-3xl h-full bg-white shadow-xl p-0 overflow-y-auto">
          <div class="flex justify-between items-center p-6 border-b">
            <h2 class="text-xl font-semibold text-[#1F2937]">{{ selectedTemplate?.title }}</h2>
            <button @click="closeDetail" class="text-slate-400 hover:text-[#FF7A59]">
              <span class="material-icons">close</span>
            </button>
          </div>
          <div>
            <div class="tabs flex border-b">
              <button v-for="tab in tabs" :key="tab" @click="activeTab = tab"
                :class="['px-6 py-3 text-sm font-medium', activeTab === tab ? 'border-b-2 border-[#0070F3] text-[#0070F3]' : 'text-[#1F2937]']">
                {{ tab }}
              </button>
            </div>
            <div class="p-6">
              <!-- Info Tab -->
              <div v-if="activeTab === 'Info'">
                <div class="mb-4">
                  <label class="block text-sm font-medium mb-1">Title</label>
                  <input v-model="selectedTemplate.title" type="text" class="w-full border px-3 py-2 rounded-md" />
                </div>
                <div class="mb-4">
                  <label class="block text-sm font-medium mb-1">Frequency</label>
                  <select v-model="selectedTemplate.frequency" class="w-full border px-3 py-2 rounded-md">
                    <option value="daily">Daily</option>
                    <option value="weekly">Weekly</option>
                    <option value="monthly">Monthly</option>
                  </select>
                </div>
                <div class="flex justify-end">
                  <button @click="updateTemplate" class="bg-[#0070F3] text-white px-4 py-2 rounded-md hover:bg-blue-700">Save</button>
                </div>
              </div>
              <!-- Questions Tab -->
              <div v-if="activeTab === 'Questions'">
                <div class="mb-6 flex justify-between items-center">
                  <div>
                    <h3 class="font-semibold text-lg text-[#1F2937]">Questions</h3>
                    <p class="text-sm text-[#6B7280] mt-1">Manage audit questions for {{ selectedTemplate?.title }}</p>
                  </div>
                  <button 
                    @click="addQuestion" 
                    class="bg-[#0070F3] text-white px-4 py-2 rounded-md hover:bg-[#005CC5] transition-colors flex items-center gap-2"
                  >
                    <span class="material-icons text-sm">add</span>
                    Add Question
                  </button>
                </div>
                
                <!-- Questions List -->
                <div class="space-y-4">
                  <div v-if="questions.length === 0" class="text-center py-8 bg-[#F9FAFB] rounded-lg border border-dashed border-[#E5E7EB]">
                    <p class="text-[#6B7280]">No questions added yet. Click 'Add Question' to get started.</p>
                  </div>
                  
                  <div 
                    v-for="(q, idx) in questions" 
                    :key="q.id || idx" 
                    class="p-4 border rounded-lg bg-white hover:shadow-sm transition-shadow"
                  >
                    <div class="space-y-4">
                      <!-- Question Text -->
                      <div>
                        <label class="block text-sm font-medium text-[#1F2937] mb-1">Question Text</label>
                        <input 
                          v-model="q.question_text" 
                          type="text" 
                          class="w-full px-3 py-2 border rounded-md focus:ring-2 focus:ring-[#0070F3] focus:border-[#0070F3] transition-colors" 
                          placeholder="Enter question text..."
                          @input="questionChanged = true"
                        />
                      </div>
                      
                      <!-- Score and Actions -->
                      <div class="flex items-center justify-between">
                        <div class="flex items-center gap-2">
                          <label class="text-sm font-medium text-[#1F2937]">Max Score:</label>
                          <input 
                            v-model="q.max_score" 
                            type="number" 
                            min="1" 
                            max="10" 
                            class="w-20 px-3 py-2 border rounded-md focus:ring-2 focus:ring-[#0070F3] focus:border-[#0070F3]" 
                            @input="questionChanged = true"
                          />
                        </div>
                        <button 
                          @click="removeQuestion(idx)" 
                          class="text-[#EF4444] hover:text-[#DC2626] px-3 py-1 rounded-md hover:bg-red-50 transition-colors flex items-center gap-1"
                        >
                          <span class="material-icons text-sm">delete</span>
                          Remove
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
                
                <!-- Save Button -->
                <div class="flex justify-end mt-6">
                  <button 
                    @click="saveQuestions" 
                    :disabled="!questionChanged"
                    :class="[
                      'px-4 py-2 rounded-md transition-colors flex items-center gap-2',
                      questionChanged 
                        ? 'bg-[#0070F3] hover:bg-[#005CC5] text-white' 
                        : 'bg-[#F3F4F6] text-[#6B7280] cursor-not-allowed'
                    ]"
                  >
                    <span class="material-icons text-sm">save</span>
                    Save Questions
                  </button>
                </div>
              </div>
              <!-- Assignments Tab -->
              <div v-if="activeTab === 'Assignments'">
                <AssignmentForm :template-id="selectedTemplate.id" @submit="assignToStaff" />
                <div class="mt-6">
                  <h3 class="font-semibold text-lg mb-3 text-[#1F2937]">Assigned To</h3>
                  
                  <!-- Empty state message -->
                  <div v-if="assignments.length === 0" class="text-center py-8 bg-[#F9FAFB] rounded-lg border border-dashed border-[#E5E7EB]">
                    <div class="flex flex-col items-center">
                      <span class="material-icons text-[#6B7280] text-3xl mb-2">assignment_ind</span>
                      <p class="text-[#1F2937] font-medium">No assignments yet for this template</p>
                      <p class="text-sm mt-2 text-[#6B7280]">Use the form above to assign this audit to staff members.</p>
                    </div>
                  </div>
                  
                  <!-- Assignment list -->
                  <div v-else class="space-y-3">
                    <AssignmentCard v-for="a in assignments" :key="a.id" :assignment="a" @complete="markComplete(a.id)" />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </transition>
    <!-- Toast Notification -->
    <Toast
      :show="toast.show"
      :message="toast.message"
      :type="toast.type"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick } from 'vue'
import TemplateCard from '../components/audit/TemplateCard.vue'
import TemplateForm from '../components/audit/TemplateForm.vue'
import AssignmentForm from '../components/audit/AssignmentForm.vue'
import AssignmentCard from '../components/audit/AssignmentCard.vue'
import Modal from '../components/Modal.vue'
import Toast from '../components/Toast.vue'
import { supabase } from '../supabase'

// Use the supabase client directly
const showCreateModal = ref(false)
const showDetail = ref(false)
const editingTemplate = ref(null)
const newAssignment = reactive({
  assigned_to: '',
  due_date: '',
})
const selectedTemplate = ref<any>(null)
const templates = ref<any[]>([])
const questions = ref<any[]>([])
const assignments = ref<any[]>([])
const activeTab = ref<'Info'|'Questions'|'Assignments'>('Info')
const tabs = ['Info', 'Questions', 'Assignments']
const questionChanged = ref(false)
const toast = ref({ show: false, message: '', type: 'success' })

function showToast(message: string, type: 'success' | 'error' = 'success') {
  toast.value = { show: true, message, type }
  setTimeout(() => {
    toast.value.show = false
  }, 3000)
}

// CRUD: Templates
async function fetchTemplates() {
  const { data, error } = await supabase.from('audit_templates').select('*').order('created_at', { ascending: false })
  if (!error) templates.value = data || []
}

function openEditModal(template: any) {
  editingTemplate.value = { ...template }
  showCreateModal.value = true
}

async function handleSubmit(formData: any) {
  try {
    if (editingTemplate.value) {
      // Update
      const { data, error } = await supabase.from('audit_templates').update({
        title: formData.title,
        frequency: formData.frequency
      }).eq('id', editingTemplate.value.id).select()
      if (!error && data && data[0]) {
        const idx = templates.value.findIndex(t => t.id === editingTemplate.value.id)
        if (idx !== -1) templates.value[idx] = data[0]
        showCreateModal.value = false
        editingTemplate.value = null
      }
    } else {
      // Create
      const { data, error } = await supabase.from('audit_templates').insert({
        title: formData.title,
        frequency: formData.frequency
      }).select()
      if (!error && data && data[0]) {
        templates.value.unshift(data[0])
        showCreateModal.value = false
        editingTemplate.value = null
      }
    }
  } catch (error) {
    console.error('Error saving template:', error)
  }
}

async function deleteTemplate(id: string) {
  if (!confirm('Delete this template?')) return
  const { error } = await supabase.from('audit_templates').delete().eq('id', id)
  if (!error) templates.value = templates.value.filter(t => t.id !== id)
}

// Template Detail (Drawer/Modal)
function openDetail(template: any) {
  try {
    // Ensure template is valid
    if (!template || !template.id) {
      showToast('Invalid template data', 'error')
      return
    }

    // Reset states
    selectedTemplate.value = { ...template }
    activeTab.value = 'Info'
    questionChanged.value = false
    questions.value = []

    // Fetch related data
    fetchQuestions()
    fetchAssignments()

    // Show detail drawer
    showDetail.value = true
  } catch (error) {
    console.error('Error opening template detail:', error)
    showToast('Error opening template details', 'error')
  }
}
function closeDetail() {
  showDetail.value = false
  selectedTemplate.value = null
  questions.value = []
  assignments.value = []
}

// CRUD: Questions
async function fetchQuestions() {
  if (!selectedTemplate.value) return
  const { data, error } = await supabase.from('audit_questions').select('*').eq('template_id', selectedTemplate.value.id).order('question_order')
  if (!error) questions.value = data || []
}
function addQuestion() {
  questions.value.push({ 
    question_text: '', 
    max_score: 1, 
    template_id: selectedTemplate.value.id 
  })
  questionChanged.value = true
}
async function removeQuestion(idx: number) {
  try {
    const q = questions.value[idx]
    if (q.id) {
      const { error } = await supabase.from('audit_questions').delete().eq('id', q.id)
      if (error) throw error
    }
    questions.value.splice(idx, 1)
    questionChanged.value = true
    showToast('Question removed', 'success')
  } catch (error) {
    console.error('Error removing question:', error)
    showToast('Error removing question', 'error')
  }
}
async function saveQuestions() {
  try {
    console.log('[DEBUG] Attempting to save questions for template:', selectedTemplate.value?.id)
    
    // Validate questions
    const invalidQuestions = questions.value.filter(q => !q.question_text?.trim() || !q.max_score)
    if (invalidQuestions.length > 0) {
      console.error('[DEBUG] Validation failed - invalid questions:', invalidQuestions)
      showToast('Please fill in all question fields', 'error')
      return
    }

    console.log('[DEBUG] Questions to save:', JSON.stringify(questions.value))

    // Upsert all questions
    for (const [i, q] of questions.value.entries()) {
      console.log(`[DEBUG] Processing question ${i}:`, q)
      if (q.id) {
        console.log(`[DEBUG] Updating existing question ${q.id}`)
        const { error } = await supabase.from('audit_questions').update({
          question_text: q.question_text,
          max_score: q.max_score,
          question_order: i + 1
        }).eq('id', q.id)
        if (error) throw error
      } else {
        console.log(`[DEBUG] Inserting new question for template ${selectedTemplate.value?.id}`)
        const { error } = await supabase.from('audit_questions').insert({
          template_id: selectedTemplate.value.id,
          question_text: q.question_text,
          max_score: q.max_score,
          question_order: i + 1
        })
        if (error) throw error
      }
    }

    console.log('[DEBUG] Questions saved successfully')
    await fetchQuestions()
    questionChanged.value = false
    showToast('Questions saved successfully', 'success')
  } catch (error) {
    console.error('[DEBUG] Error saving questions:', error)
    showToast('Error saving questions', 'error')
  }
}

// CRUD: Assignments
async function fetchAssignments() {
  if (!selectedTemplate.value) return
  try {
    console.log('[DEBUG] Fetching assignments for template:', selectedTemplate.value.id)
    
    // Use simple field selection without joins
    const { data, error } = await supabase
      .from('audit_assignments')
      .select('id, template_id, due_date, status, created_at, assigned_to, assigned_by')
      .eq('template_id', selectedTemplate.value.id)
      .order('created_at', { ascending: false })
    
    if (error) {
      console.error('[DEBUG] Assignment fetch error:', error)
      showToast('Failed to load assignments', 'error')
      assignments.value = []
      return
    }
    
    // If we need user details, we can fetch them separately
    // This avoids the foreign key relationship issue
    if (data && data.length > 0) {
      // Get unique user IDs from assignments
      const userIds = [...new Set(
        data.flatMap(a => [a.assigned_to, a.assigned_by].filter(Boolean))
      )]
      
      if (userIds.length > 0) {
        const { data: users } = await supabase
          .from('profiles')
          .select('id, full_name, email')
          .in('id', userIds)
        
        // Create a lookup map for users
        const userMap = (users || []).reduce((map, user) => {
          map[user.id] = user
          return map
        }, {})
        
        // Attach user data to assignments
        data.forEach(assignment => {
          assignment.assignedToUser = userMap[assignment.assigned_to] || { full_name: 'Unknown User' }
          assignment.assignedByUser = userMap[assignment.assigned_by] || { full_name: 'Unknown User' }
        })
      }
    }
    
    console.log('[DEBUG] Fetched assignments:', data)
    assignments.value = data || []
  } catch (err) {
    console.error('[DEBUG] Unexpected error in fetchAssignments:', err)
    showToast('Error loading assignments', 'error')
    assignments.value = []
  }
}
async function assignToStaff(assignment: any) {
  assignment.template_id = selectedTemplate.value.id
  const { data, error } = await supabase.from('audit_assignments').insert(assignment).select('*, assigned_to:profiles(*), assigned_by:profiles(*)')
  if (!error && data && data[0]) assignments.value.unshift(data[0])
}
async function markComplete(id: string) {
  await supabase.from('audit_assignments').update({ status: 'completed' }).eq('id', id)
  fetchAssignments()
}

async function updateTemplate() {
  if (!selectedTemplate.value) return
  const { data, error } = await supabase.from('audit_templates').update({
    title: selectedTemplate.value.title,
    frequency: selectedTemplate.value.frequency
  }).eq('id', selectedTemplate.value.id).select()
  if (!error && data && data[0]) {
    const idx = templates.value.findIndex(t => t.id === selectedTemplate.value.id)
    if (idx !== -1) templates.value[idx] = data[0]
  }
}

// UX: Open detail on card click
function handleCardEdit(template: any) {
  openEditModal(template)
}
function handleCardDetail(template: any) {
  openDetail(template)
}

// Add error handling wrapper for Supabase queries
const safeQuery = async (queryFn) => {
  try {
    return await queryFn()
  } catch (err) {
    console.error('[DEBUG] Database query error:', err)
    showToast('Database operation failed', 'error')
    return { data: null, error: err }
  }
}

// Check if tables exist before accessing them
async function checkTablesExist() {
  try {
    // First check if audit_templates exists - this is our core table
    const { error: templatesError } = await supabase
      .from('audit_templates')
      .select('id')
      .limit(1)
    
    if (templatesError) {
      console.error('[DEBUG] Templates table error:', templatesError)
      showToast('Database setup incomplete. Please run migrations.', 'error')
      return false
    }
    
    return true
  } catch (err) {
    console.error('[DEBUG] Database connection error:', err)
    showToast('Cannot connect to database', 'error')
    return false
  }
}

// On mount, check database and fetch templates
onMounted(async () => {
  const tablesExist = await checkTablesExist()
  if (tablesExist) {
    await fetchTemplates()
  }
})
</script>

<style scoped>
.template-grid {
  min-height: 60vh;
}
</style>
