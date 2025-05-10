<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50">
    <Card class="w-full max-w-md">
      <h2 class="font-heading text-2xl mb-4 text-center">Sign Up</h2>
      <form @submit.prevent="onSignup">
        <div v-if="error" class="mb-4 p-3 rounded bg-error/10 text-error text-sm">
          {{ error }}
        </div>
        <div v-if="success" class="mb-4 p-3 rounded bg-success/10 text-success text-sm">
          {{ success }}
        </div>
        <Input v-model="email" type="email" placeholder="Email" class="mb-3" required />
        <Input v-model="password" type="password" placeholder="Password" class="mb-4" required minlength="6" />
        <p class="text-sm text-secondary mb-4">Password must be at least 6 characters long</p>
        <Button color="primary" class="w-full mb-2" :disabled="loading">
          <span v-if="loading">Signing up...</span>
          <span v-else>Sign Up</span>
        </Button>
        <div class="flex justify-between text-sm mt-2">
          <RouterLink to="/" class="text-primary hover:underline">Already have an account?</RouterLink>
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
const success = ref('')

async function onSignup() {
  try {
    if (!email.value || !password.value) {
      error.value = 'Please fill in all fields'
      return
    }

    if (!email.value.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) {
      error.value = 'Please enter a valid email address'
      return
    }

    if (password.value.length < 6) {
      error.value = 'Password must be at least 6 characters long'
      return
    }

    loading.value = true
    error.value = ''
    success.value = ''

    const { data, error: signupError } = await supabase.auth.signUp({
    email: email.value,
    password: password.value,
  })
    loading.value = false
    if (signupError) {
      error.value = signupError.message || 'Failed to sign up'
      console.error('Signup error:', signupError)
    } else if (!data.user) {
      error.value = 'No user created. Please try again.'
    } else {
      success.value = 'Signup successful! Check your email to confirm your account.'
      // Redirect to login after 3 seconds
      setTimeout(() => {
        router.push('/')
      }, 3000)
    }
  } catch (e) {
    loading.value = false
    error.value = 'An unexpected error occurred'
    console.error('Signup error:', e)
  }
}
</script>
