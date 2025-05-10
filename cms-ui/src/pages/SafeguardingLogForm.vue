<template>
  <Layout>
    <nav class="text-xs text-gray-400 mb-2">
      <router-link :to="{ name: 'Dashboard' }" class="hover:underline">Dashboard</router-link> /
      <router-link :to="{ name: 'Safeguarding' }" class="hover:underline">Safeguarding</router-link> /
      <span class="text-primary">Log Safeguarding Case</span>
    </nav>
    <h1 class="font-heading text-2xl mb-6">Safeguarding Log Entry</h1>
    <MultiStepForm :steps="steps" @finish="submit">
      <template #default="{ step, goToStep, isLast }">
        <div v-if="step === 0">
          <h2 class="font-heading text-lg mb-2">Case Details</h2>
          <select v-model="form.type" class="input mb-2 w-full">
            <option value="">Select Type</option>
            <option value="Allegation">Allegation</option>
            <option value="Risk">Risk</option>
            <option value="Concern">Concern</option>
          </select>
          <div v-if="errors.type" class="text-error text-xs mb-1">{{ errors.type }}</div>
          <input v-model="form.description" placeholder="Description" class="input mb-2 w-full" />
          <div v-if="errors.description" class="text-error text-xs mb-1">{{ errors.description }}</div>
          <div class="mb-2">
            <label for="file-upload" class="block mb-1">Upload supporting document:</label>
            <div
              class="border-2 border-dashed rounded p-4 text-center cursor-pointer bg-gray-50 hover:bg-gray-100 mb-2"
              @dragover.prevent
              @drop.prevent="onDropFile"
              @click="() => $refs.fileInput.click()"
            >
              <input ref="fileInput" type="file" class="hidden" @change="onFileChange" />
              <span v-if="!form.file">Drag & drop or click to select file</span>
              <span v-else>{{ form.file.name }}</span>
            </div>
            <div v-if="form.file && filePreview" class="mb-2">
              <div class="text-xs text-gray-500 mb-1">Preview:</div>
              <img v-if="filePreviewType === 'image'" :src="filePreview" class="max-h-40 mx-auto rounded border" />
              <div v-else class="text-xs text-gray-600">{{ form.file.name }}</div>
            </div>
          </div>
        </div>
        <div v-else-if="step === 1">
          <h2 class="font-heading text-lg mb-2">Assign Users</h2>
          <input v-model="form.assigned_users" placeholder="User emails (comma separated)" class="input mb-2 w-full" @input="validateEmails" />
          <div v-if="errors.assigned_users" class="text-error text-xs mb-1">{{ errors.assigned_users }}</div>
        </div>
        <div v-else-if="step === 2">
          <h2 class="font-heading text-lg mb-2">Confirmation</h2>
          <div class="mb-2">Please review your log entry:</div>
          <ul class="mb-2">
            <li><b>Type:</b> {{ form.type }}</li>
            <li><b>Description:</b> {{ form.description }}</li>
            <li><b>Assigned Users:</b> {{ form.assigned_users }}</li>
          </ul>
        </div>
      </template>
    </MultiStepForm>
  </Layout>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import Layout from '../components/Layout.vue'
import MultiStepForm from '../components/MultiStepForm.vue'
const steps = [
  { label: 'Details' },
  { label: 'Assign' },
  { label: 'Confirm' }
]
const form = ref({ type: '', description: '', assigned_users: '', file: null })
const errors = ref<{ [key: string]: string }>({})
import { supabase } from '../supabase'
import { useRouter } from 'vue-router'
const router = useRouter()
const submitting = ref(false)
const success = ref(false)
const errorMsg = ref('')
const showModal = ref(false)
const filePreview = ref('')
const filePreviewType = ref('')

function onFileChange(e) {
  const file = e.target.files[0]
  if (file) {
    form.value.file = file
    setFilePreview(file)
  }
}
function onDropFile(e) {
  const file = e.dataTransfer.files[0]
  if (file) {
    form.value.file = file
    setFilePreview(file)
  }
}
function setFilePreview(file) {
  if (file.type && file.type.startsWith('image/')) {
    filePreviewType.value = 'image'
    const reader = new FileReader()
    reader.onload = e => { filePreview.value = e.target.result }
    reader.readAsDataURL(file)
  } else {
    filePreviewType.value = 'other'
    filePreview.value = ''
  }
}

function validateEmails() {
  if (!form.value.assigned_users) {
    errors.value.assigned_users = 'Assigned users are required.'
    return
  }
  const emails = form.value.assigned_users.split(',').map(e => e.trim())
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  for (const email of emails) {
    if (!emailRegex.test(email)) {
      errors.value.assigned_users = `Invalid email: ${email}`
      return
    }
  }
  errors.value.assigned_users = ''
}

// Navigation guard for unsaved changes
let isDirty = false
watch(form, () => { isDirty = true }, { deep: true })
if (typeof window !== 'undefined') {
  window.addEventListener('beforeunload', (e) => {
    if (isDirty && !success.value) {
      e.preventDefault()
      e.returnValue = ''
    }
  })
}
if (typeof window !== 'undefined' && typeof useRouter === 'function') {
  router.beforeEach((to, from, next) => {
    if (isDirty && !success.value) {
      if (confirm('You have unsaved changes. Are you sure you want to leave?')) {
        next()
      } else {
        next(false)
      }
    } else {
      next()
    }
  })
}

function validate() {
  errors.value = {}
  if (!form.value.type) errors.value.type = 'Type is required.'
  if (!form.value.description) errors.value.description = 'Description is required.'
  if (!form.value.assigned_users) errors.value.assigned_users = 'Assigned users are required.'
  return Object.keys(errors.value).length === 0
}
async function submit() {
  if (!validate()) return
  submitting.value = true
  errorMsg.value = ''
  try {
    let fileUrl = ''
    if (form.value.file) {
      const { data, error: uploadError } = await supabase.storage.from('safeguarding-files').upload(`safeguarding/${Date.now()}_${form.value.file.name}`, form.value.file)
      if (uploadError) throw uploadError
      fileUrl = data?.path ? supabase.storage.from('safeguarding-files').getPublicUrl(data.path).publicUrl : ''
    }
    const { data: users } = await supabase.from('auth.users').select('id, email')
    const assignedUsers = form.value.assigned_users.split(',').map(u => u.trim())
    const userQuery = assignedUsers.map(email => ({ email }))
    const { data: userResults } = await supabase.from('auth.users').select('id').in('email', userQuery)
    const userIds = userResults.map(user => user.id)
    const { error } = await supabase.from('safeguarding').insert([
      { type: form.value.type, description: form.value.description, assigned_users: userIds, file_url: fileUrl }
    ])
    if (error) throw error
    success.value = true
    showModal.value = true
    setTimeout(() => {
      showModal.value = false
      router.push({ name: 'Safeguarding' })
    }, 2000)
  } catch (err) {
    errorMsg.value = err.message || 'Submission failed.'
  } finally {
    submitting.value = false
  }
}
</script>
