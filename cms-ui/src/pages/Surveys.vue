<template>
  <Layout>
    <div class="page-header">
      <h1 class="page-title">Surveys</h1>
      <Button color="primary" @click="showCreate = true">New Survey</Button>
    </div>
    
    <div class="card-container">
      <div class="data-card">
        <Table>
          <template #header>
            <th>Title</th>
            <th>Status</th>
            <th>Responses</th>
            <th>Actions</th>
          </template>
          <tr v-for="survey in surveys" :key="survey.id">
            <td>{{ survey.title }}</td>
            <td>
              <span class="status-badge" :class="getStatusClass(survey.status)">{{ survey.status }}</span>
            </td>
            <td>{{ survey.responses_count }}</td>
            <td>
              <Button color="secondary" size="sm" @click="editSurvey(survey)">Edit</Button>
            </td>
          </tr>
        </Table>
      </div>
    </div>
    <Modal :show="showCreate" @close="showCreate = false">
      <h2 class="font-heading text-xl mb-2">Create Survey</h2>
      <form @submit.prevent="createSurvey">
        <Input v-model="newSurvey.title" placeholder="Title" class="mb-2" />
        <select v-model="newSurvey.status" class="mb-2 p-2 border rounded w-full">
          <option value="draft">Draft</option>
          <option value="published">Published</option>
        </select>
        <Button color="primary" class="w-full">Create</Button>
      </form>
    </Modal>
    <Modal :show="!!editTarget" @close="editTarget = null">
      <h2 class="font-heading text-xl mb-2">Edit Survey</h2>
      <form @submit.prevent="updateSurvey">
        <Input v-model="editTarget.title" placeholder="Title" class="mb-2" />
        <select v-model="editTarget.status" class="mb-2 p-2 border rounded w-full">
          <option value="draft">Draft</option>
          <option value="published">Published</option>
        </select>
        <Button color="primary" class="w-full">Update</Button>
      </form>
    </Modal>
  </Layout>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import Layout from '../components/Layout.vue'
import Table from '../components/Table.vue'
import Button from '../components/Button.vue'
import Modal from '../components/Modal.vue'
import Input from '../components/Input.vue'
import { supabase } from '../supabase'

// Helper function for status badges
function getStatusClass(status: string) {
  switch(status.toLowerCase()) {
    case 'draft': return 'badge-accent';
    case 'published': return 'badge-success';
    default: return 'badge-primary';
  }
}

const surveys = ref<any[]>([])
const showCreate = ref(false)
const newSurvey = ref({ title: '', status: 'draft' })
const editTarget = ref<any | null>(null)
let surveySubscription: any = null

async function fetchSurveys() {
  const { data, error } = await supabase.from('surveys').select('*')
  if (error) {
    console.error('Error fetching surveys:', error)
    return
  }
  surveys.value = data?.map(s => ({
    ...s,
    responses_count: Array.isArray(s.responses) ? s.responses.length : 0
  })) || []
}

onMounted(() => {
  fetchSurveys();
  // Real-time updates
  surveySubscription = supabase
    .channel('surveys')
    .on('postgres_changes', { event: '*', schema: 'public', table: 'surveys' }, payload => {
      fetchSurveys()
    })
    .subscribe()
})

onUnmounted(() => {
  if (surveySubscription) supabase.removeChannel(surveySubscription)
})

async function createSurvey() {
  await supabase.from('surveys').insert([
    {
      title: newSurvey.value.title,
      status: newSurvey.value.status,
      responses: [],
    },
  ])
  showCreate.value = false
  fetchSurveys()
}

function editSurvey(survey: any) {
  editTarget.value = { ...survey }
}

async function updateSurvey() {
  if (!editTarget.value) return
  await supabase.from('surveys').update({
    title: editTarget.value.title,
    status: editTarget.value.status,
  }).eq('id', editTarget.value.id)
  editTarget.value = null
  fetchSurveys()
}
</script>

<style scoped>
/* Page Header */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.page-title {
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--color-text, #1F2937);
  margin: 0;
}

/* Card Container */
.card-container {
  margin-bottom: 2rem;
}

.data-card {
  background-color: white;
  border-radius: 0.75rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  overflow: hidden;
}

/* Status Badges */
.status-badge {
  display: inline-flex;
  align-items: center;
  padding: 0.25rem 0.5rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 500;
}

.badge-primary {
  background-color: rgba(0, 112, 243, 0.1);
  color: var(--color-primary, #0070F3);
}

.badge-accent {
  background-color: rgba(255, 122, 89, 0.1);
  color: var(--color-accent, #FF7A59);
}

.badge-success {
  background-color: rgba(16, 185, 129, 0.1);
  color: var(--color-success, #10B981);
}

/* Form Styles */
form {
  width: 100%;
}

select {
  width: 100%;
  padding: 0.625rem;
  border: 1px solid #E5E7EB;
  border-radius: 0.375rem;
  background-color: white;
  color: var(--color-text, #1F2937);
  font-size: 0.875rem;
  transition: border-color 0.15s ease;
  margin-bottom: 1rem;
}

select:focus {
  outline: none;
  border-color: var(--color-primary, #0070F3);
  box-shadow: 0 0 0 2px rgba(0, 112, 243, 0.2);
}

/* Modal Styles */
h2 {
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--color-text, #1F2937);
  margin-bottom: 1rem;
}
</style>
