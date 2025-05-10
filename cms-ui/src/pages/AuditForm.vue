<template>
  <Layout>
    <div class="max-w-2xl mx-auto">
      <div class="flex items-center justify-between mb-6">
        <h1 class="font-heading text-2xl">New Audit</h1>
        <router-link :to="{ name: 'Audits' }">
          <Button color="secondary">Cancel</Button>
        </router-link>
      </div>

      <Card class="p-6">
        <form @submit.prevent="createAudit" class="space-y-6">
          <div>
            <label class="block text-sm font-medium mb-2">Title</label>
            <Input 
              v-model="audit.title" 
              placeholder="Enter audit title" 
              :error="errors.title"
              required
            />
          </div>

          <div>
            <label class="block text-sm font-medium mb-2">Description</label>
            <textarea
              v-model="audit.description"
              rows="4"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
              placeholder="Enter audit description"
            ></textarea>
          </div>

          <div>
            <label class="block text-sm font-medium mb-2">Status</label>
            <select 
              v-model="audit.status"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
              required
            >
              <option value="open">Open</option>
              <option value="closed">Closed</option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium mb-2">Assigned Users</label>
            <select
              v-model="audit.assigned_users"
              multiple
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
              :class="{ 'border-error': errors.assigned_users }"
              required
            >
              <option v-for="user in users" :key="user.id" :value="user.id">
                {{ user.name }}
              </option>
            </select>
            <p v-if="errors.assigned_users" class="mt-1 text-xs text-error">{{ errors.assigned_users }}</p>
            <p v-else class="mt-1 text-xs text-gray-500">Hold Ctrl/Cmd to select multiple users</p>
          </div>

          <div class="pt-4">
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
