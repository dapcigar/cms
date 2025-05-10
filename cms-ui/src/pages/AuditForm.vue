<template>
  <Layout>
    <div class="max-w-2xl mx-auto">
      <div class="flex items-center justify-between mb-6">
        <h1 class="font-heading text-2xl">New Audit</h1>
        <router-link :to="{ name: 'Audits' }">
          <Button color="secondary">Cancel</Button>
        </router-link>
      </div>

      <Card type="primary" class="audit-card">
        <form @submit.prevent="createAudit" class="audit-form">
          <div class="form-group">
            <label class="form-label">Title</label>
            <Input 
              v-model="audit.title" 
              placeholder="Enter audit title" 
              :error="errors.title"
              required
              class="form-input"
            />
          </div>

          <div class="form-group">
            <label class="form-label">Description</label>
            <textarea
              v-model="audit.description"
              rows="4"
              class="form-textarea"
              placeholder="Enter audit description"
            ></textarea>
          </div>

          <div class="form-group">
            <label class="form-label">Status</label>
            <select 
              v-model="audit.status"
              class="form-select"
              required
            >
              <option value="open">Open</option>
              <option value="closed">Closed</option>
            </select>
          </div>

          <div class="form-group">
            <label class="form-label">Assigned Users</label>
            <select
              v-model="audit.assigned_users"
              multiple
              class="form-select"
              :class="{ 'border-error': errors.assigned_users }"
              required
            >
              <option v-for="user in users" :key="user.id" :value="user.id">
                {{ user.name }}
              </option>
            </select>
            <p v-if="errors.assigned_users" class="form-error">{{ errors.assigned_users }}</p>
            <p v-else class="form-help">Hold Ctrl/Cmd to select multiple users</p>
          </div>

          <div class="form-actions">
            <Button 
              type="submit" 
              color="primary" 
              class="w-full"
              :loading="loading"
              :disabled="loading"
            >Create Audit</Button>
          </div>
        </form>
      </Card>
    </div>
  </Layout>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import Layout from '../components/Layout.vue'
import Card from '../components/Card.vue'
import Button from '../components/Button.vue'
import Input from '../components/Input.vue'
import { supabase } from '../supabase'

const router = useRouter()
const users = ref<any[]>([])
const loading = ref(false)
const errors = ref({
  title: '',
  assigned_users: ''
})

const audit = ref({
  title: '',
  description: '',
  status: 'open',
  assigned_users: []
})

async function fetchUsers() {
  const { data, error } = await supabase
    .from('users')
    .select('id, name')
    .order('name')

  if (error) {
    console.error('Error fetching users:', error)
    return
  }

  users.value = data || []
}

async function createAudit() {
  // Reset errors
  errors.value = {
    title: '',
    assigned_users: ''
  }

  // Validate
  if (!audit.value.title.trim()) {
    errors.value.title = 'Title is required'
    return
  }

  if (!audit.value.assigned_users.length) {
    errors.value.assigned_users = 'Please assign at least one user'
    return
  }

  loading.value = true

  try {
    const { data, error } = await supabase
      .from('audits')
      .insert([{
        title: audit.value.title.trim(),
        description: audit.value.description.trim(),
        status: audit.value.status,
        assigned_users: audit.value.assigned_users,
        created_at: new Date().toISOString()
      }])
      .select()
      .single()

    if (error) throw error

    // Log the creation
    await supabase.from('audit_logs').insert({
      audit_id: data.id,
      message: 'Audit created',
      icon: 'add'
    })

    // Notify assigned users
    await Promise.all(audit.value.assigned_users.map(userId =>
      supabase.from('notifications').insert({
        user_id: userId,
        title: 'New Audit Assigned',
        message: `You have been assigned to the audit: ${audit.value.title}`,
        created_at: new Date().toISOString()
      })
    ))

    router.push({ name: 'AuditDetail', params: { id: data.id } })
  } catch (error) {
    console.error('Error creating audit:', error)
  } finally {
    loading.value = false
  }
}

onMounted(fetchUsers)
</script>

<style scoped>
.audit-card {
  padding: 1.75rem;
  transition: all 0.2s ease;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.audit-form {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.form-group {
  margin-bottom: 0.5rem;
}

.form-label {
  display: block;
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--color-text);
  margin-bottom: 0.5rem;
}

.form-input {
  width: 100%;
  transition: all 0.2s ease;
}

.form-textarea {
  width: 100%;
  padding: 0.625rem 0.75rem;
  border: 1px solid #E5E7EB;
  border-radius: 0.375rem;
  transition: all 0.2s ease;
  font-size: 0.875rem;
  color: var(--color-text);
  resize: vertical;
}

.form-textarea:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 2px rgba(0, 112, 243, 0.2);
}

.form-select {
  width: 100%;
  padding: 0.625rem 0.75rem;
  border: 1px solid #E5E7EB;
  border-radius: 0.375rem;
  transition: all 0.2s ease;
  background-color: white;
  color: var(--color-text);
  font-size: 0.875rem;
  appearance: none;
  background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3e%3cpath stroke='%236b7280' stroke-linecap='round' stroke-linejoin='round' stroke-width='1.5' d='M6 8l4 4 4-4'/%3e%3c/svg%3e");
  background-position: right 0.5rem center;
  background-repeat: no-repeat;
  background-size: 1.5em 1.5em;
  padding-right: 2.5rem;
}

.form-select:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 2px rgba(0, 112, 243, 0.2);
}

.form-select[multiple] {
  height: 8rem;
  background-image: none;
  padding-right: 0.75rem;
}

.form-error {
  margin-top: 0.25rem;
  font-size: 0.75rem;
  color: var(--color-error);
}

.form-help {
  margin-top: 0.25rem;
  font-size: 0.75rem;
  color: rgba(31, 41, 55, 0.7);
}

.form-actions {
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid rgba(0, 0, 0, 0.05);
}

.border-error {
  border-color: var(--color-error);
}
</style>
