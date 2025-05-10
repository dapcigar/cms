<template>
  <Layout>
    <nav class="text-xs text-gray-400 mb-2">
      <router-link :to="{ name: 'Dashboard' }" class="hover:underline">Dashboard</router-link> /
      <router-link :to="{ name: 'Onboarding' }" class="hover:underline">Onboarding</router-link> /
      <span class="text-primary">New User</span>
    </nav>
    <h1 class="font-heading text-2xl mb-6">Staff Onboarding</h1>
    <MultiStepForm :steps="steps" @finish="submit">
      <template #default="{ step, goToStep, isLast }">
        <div v-if="step === 0">
          <h2 class="font-heading text-lg mb-2">Personal Details</h2>
          <input v-model="form.name" placeholder="Full Name" class="input mb-2 w-full" />
          <div v-if="errors.name" class="text-error text-xs mb-1">{{ errors.name }}</div>
          <input v-model="form.email" type="email" placeholder="Email" class="input mb-2 w-full" @input="validateEmail" />
          <div v-if="errors.email" class="text-error text-xs mb-1">{{ errors.email }}</div>
        </div>
        <div v-else-if="step === 1">
          <h2 class="font-heading text-lg mb-2">Role & Department</h2>
          <select v-model="form.role" class="input mb-2 w-full">
            <option value="">Select Role</option>
            <option v-for="role in roles" :key="role" :value="role">{{ role }}</option>
          </select>
          <div v-if="errors.role" class="text-error text-xs mb-1">{{ errors.role }}</div>
          <input v-model="form.department" placeholder="Department" class="input mb-2 w-full" />
          <div class="mb-2">
            <label for="file-upload" class="block mb-1">Upload profile photo:</label>
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
          <div v-if="errors.department" class="text-error text-xs mb-1">{{ errors.department }}</div>
        </div>
        <div v-else-if="step === 2">
          <h2 class="font-heading text-lg mb-2">Confirmation</h2>
          <div class="mb-2">Please review your details:</div>
          <ul class="mb-2">
            <li><b>Name:</b> {{ form.name }}</li>
            <li><b>Email:</b> {{ form.email }}</li>
            <li><b>Role:</b> {{ form.role }}</li>
            <li><b>Department:</b> {{ form.department }}</li>
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
  { label: 'Personal' },
  { label: 'Role' },
  { label: 'Confirm' }
]
const form = ref({ name: '', email: '', role: '', department: '', file: null })
const errors = ref<{ [key: string]: string }>({})
const roles = ['Nurse', 'Doctor', 'Care Assistant', 'Manager', 'Admin']
import { supabase } from '../supabase'
import { useRouter } from 'vue-router'
const router = useRouter()
const submitting = ref(false)
const success = ref(false)
const errorMsg = ref('')
const filePreview = ref('')
const filePreviewType = ref('')
const isDirty = ref(false)

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

function validateEmail() {
  if (!form.value.email) {
    errors.value.email = 'Email is required.'
    return
  }
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  if (!emailRegex.test(form.value.email)) {
    errors.value.email = 'Invalid email format.'
    return
  }
  errors.value.email = ''
}

const showModal = ref(false)
function validate() {
  errors.value = {}
  if (!form.value.name) errors.value.name = 'Name is required.'
  if (!form.value.email) errors.value.email = 'Email is required.'
  if (!form.value.role) errors.value.role = 'Role is required.'
  if (!form.value.department) errors.value.department = 'Department is required.'
  return Object.keys(errors.value).length === 0
}
async function submit() {
  if (!validate()) return
  submitting.value = true
  errorMsg.value = ''
  try {
    const { error } = await supabase.from('users').insert([
      { name: form.value.name, email: form.value.email, role: form.value.role, department: form.value.department }
    ])
    if (error) throw error
    success.value = true
    showModal.value = true
    setTimeout(() => {
      showModal.value = false
      router.push({ name: 'Dashboard' })
    }, 2000)
  } catch (err: any) {
    errorMsg.value = err.message || 'Submission failed.'
  } finally {
    submitting.value = false
  }
}
</script>
