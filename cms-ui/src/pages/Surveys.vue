<template>
  <Layout>
    <div class="flex justify-between items-center mb-6">
      <h1 class="font-heading text-2xl">Surveys</h1>
      <Button color="primary" @click="showCreate = true">New Survey</Button>
    </div>
    <Table>
      <template #header>
        <th class="text-left p-2">Title</th>
        <th class="text-left p-2">Status</th>
        <th class="text-left p-2">Responses</th>
        <th class="text-left p-2">Actions</th>
      </template>
      <tr v-for="survey in surveys" :key="survey.id">
        <td class="p-2">{{ survey.title }}</td>
        <td class="p-2">{{ survey.status }}</td>
        <td class="p-2">{{ survey.responses_count }}</td>
        <td class="p-2">
          <Button color="secondary" size="sm" @click="editSurvey(survey)">Edit</Button>
        </td>
      </tr>
    </Table>
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
import { ref, onMounted } from 'vue'
import Layout from '../components/Layout.vue'
import Table from '../components/Table.vue'
import Button from '../components/Button.vue'
import Modal from '../components/Modal.vue'
import Input from '../components/Input.vue'
import { supabase } from '../supabase'

const surveys = ref<any[]>([])
const showCreate = ref(false)
const newSurvey = ref({ title: '', status: 'draft' })
const editTarget = ref<any | null>(null)
let surveySubscription: any = null

async function fetchSurveys() {
  const { data, error } = await supabase.from('surveys').select('*')
  if (!error) surveys.value = data?.map(s => ({ ...s, responses_count: s.responses?.length || 0 })) || []
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
