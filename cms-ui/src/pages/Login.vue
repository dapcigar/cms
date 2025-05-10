<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50">
    <Card class="w-full max-w-md">
      <h2 class="font-heading text-2xl mb-4 text-center">Sign In</h2>
      <form @submit.prevent="onLogin">
        <div v-if="error" class="mb-4 p-3 rounded bg-error/10 text-error text-sm">
          {{ error }}
        </div>
        <Input v-model="email" type="email" placeholder="Email" class="mb-3" required />
        <Input v-model="password" type="password" placeholder="Password" class="mb-4" required minlength="6" />
        <Button color="primary" class="w-full mb-2" :disabled="loading">
          <span v-if="loading">Signing in...</span>
          <span v-else>Sign In</span>
        </Button>
        <div class="flex justify-between text-sm mt-2">
          <RouterLink to="/forgot-password" class="text-primary hover:underline">Forgot password?</RouterLink>
          <RouterLink to="/signup" class="text-primary hover:underline">Sign up</RouterLink>
        </div>
      </form>
    </Card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import Card from '../components/Card.vue'
import Input from '../components/Input.vue'
import Button from '../components/Button.vue'
import { supabase } from '../supabase'

const router = useRouter()

// Check if user is already logged in
onMounted(async () => {
  const { data: { session } } = await supabase.auth.getSession()
  if (session) {
    router.push('/dashboard')
  }
})

const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')

async function onLogin() {
  try {
    if (!email.value || !password.value) {
      error.value = 'Please fill in all fields'
      return
    }

    if (!email.value.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) {
      error.value = 'Please enter a valid email address'
      return
    }

    loading.value = true
    error.value = ''

    const { data, error: loginError } = await supabase.auth.signInWithPassword({
    email: email.value,
    password: password.value,
  })
    loading.value = false
    if (loginError) {
      error.value = loginError.message || 'Failed to sign in'
      console.error('Login error:', loginError)
    } else if (!data.session) {
      error.value = 'No session created. Please try again.'
    } else {
      router.push('/dashboard')
    }
  } catch (e) {
    loading.value = false
    error.value = 'An unexpected error occurred'
    console.error('Login error:', e)
  }
}
</script>
