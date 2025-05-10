<template>
  <Layout>
    <nav class="text-xs text-gray-400 mb-2">
      <router-link :to="{ name: 'Dashboard' }" class="hover:underline">Dashboard</router-link> /
      <router-link :to="{ name: 'Incidents' }" class="hover:underline">Incidents</router-link> /
      <span class="text-primary">Report New Incident</span>
    </nav>
    <h1 class="font-heading text-2xl mb-6">Report New Incident</h1>
    <MultiStepForm :steps="steps" @finish="submit">
      <template #default="{ step, goToStep, isLast }">
        <div v-if="step === 0">
          <h2 class="font-heading text-lg mb-2">Incident Details</h2>
          <input v-model="form.type" placeholder="Type" class="input mb-2 w-full" />
          <input v-model="form.description" placeholder="Description" class="input mb-2 w-full" />
          <select v-model="form.status" class="input mb-2 w-full">
            <option value="">Select Status</option>
            <option value="open">Open</option>
            <option value="resolved">Resolved</option>
          </select>
          <div v-if="errors.status" class="text-error text-xs mb-1">{{ errors.status }}</div>
        </div>
        <div v-else-if="step === 1">
          <h2 class="font-heading text-lg mb-2">Assign Users</h2>
          <input v-model="form.assigned_users" placeholder="User emails (comma separated)" class="input mb-2 w-full" @input="validateEmails" />
          <div v-if="errors.assigned_users" class="text-error text-xs mb-1">{{ errors.assigned_users }}</div>
        </div>
        <div v-else-if="step === 2">
          <h2 class="font-heading text-lg mb-2">Confirmation</h2>
          <div class="mb-2">Please review your incident:</div>
          <ul class="mb-2">
            <li><b>Type:</b> {{ form.type }}</li>
            <li><b>Description:</b> {{ form.description }}</li>
            <li><b>Status:</b> {{ form.status }}</li>
            <li><b>Assigned Users:</b> {{ form.assigned_users }}</li>
          </ul>
        </div>
      </template>
    </MultiStepForm>
    <div v-if="success" class="text-success mt-4">Incident reported successfully!</div>
    <div v-if="errorMsg" class="text-error mt-4">{{ errorMsg }}</div>
  </Layout>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import Layout from '../components/Layout.vue'
import MultiStepForm from '../components/MultiStepForm.vue'
import { supabase } from '../supabase'
const steps = [
  { label: 'Details' },
  { label: 'Assign' },
  { label: 'Confirm' }
]
const form = ref({ type: '', description: '', status: '', assigned_users: '', file: null })
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

function onFileChange(e: any) {
  const file = e.target.files[0]
  if (file) {
    form.value.file = file
    setFilePreview(file)
  }
}
function onDropFile(e: any) {
  const file = e.dataTransfer.files[0]
  if (file) {
    form.value.file = file
    setFilePreview(file)
  }
}
function setFilePreview(file: File) {
  if (file.type.startsWith('image/')) {
    filePreviewType.value = 'image'
    const reader = new FileReader()
    reader.onload = e => { filePreview.value = e.target?.result as string }
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
// Vue Router navigation guard (for Vue Router 4+)
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
  if (!form.value.status) errors.value.status = 'Status is required.'
  if (!form.value.assigned_users) errors.value.assigned_users = 'Assigned users are required.'
  validateEmails()
  return Object.keys(errors.value).every(k => !errors.value[k])
}
async function submit() {
  if (!validate()) return
  submitting.value = true
  errorMsg.value = ''
  try {
    let fileUrl = ''
    if (form.value.file) {
      const { data, error: uploadError } = await supabase.storage.from('incident-files').upload(`incidents/${Date.now()}_${form.value.file.name}`, form.value.file)
      if (uploadError) throw uploadError
      fileUrl = data?.path ? supabase.storage.from('incident-files').getPublicUrl(data.path).publicUrl : ''
    }
    const { error } = await supabase.from('incidents').insert([
      { type: form.value.type, description: form.value.description, status: form.value.status, assigned_users: form.value.assigned_users.split(',').map(u => u.trim()), file_url: fileUrl }
    ])
    if (error) throw error
    success.value = true
    showModal.value = true
    setTimeout(() => {
      showModal.value = false
      router.push({ name: 'Incidents' })
    }, 2000)
  } catch (err) {
    errorMsg.value = err.message || 'Submission failed.'
  } finally {
    submitting.value = false
  }
}
</script>
