<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50">
    <div class="w-full max-w-md">
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-primary mb-2">Care Management System</h1>
        <p class="text-slate-600">Create your account to get started</p>
      </div>
      
      <Card class="w-full">
        <h2 class="text-2xl font-semibold mb-6 text-center text-slate-800">Sign Up</h2>
        
        <form @submit.prevent="onSignup">
          <div v-if="error" class="mb-6 p-4 rounded bg-red-50 border-l-4 border-error text-error text-sm">
            {{ error }}
          </div>
          
          <div v-if="success" class="mb-6 p-4 rounded bg-green-50 border-l-4 border-success text-success text-sm">
            {{ success }}
          </div>
          
          <div class="form-group mb-4">
            <label class="form-label block mb-2 text-sm font-medium text-slate-700">Email Address</label>
            <Input 
              v-model="email" 
              type="email" 
              placeholder="Enter your email" 
              class="w-full p-3 border rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary transition" 
              required 
            />
          </div>
          
          <div class="form-group mb-6">
            <label class="form-label block mb-2 text-sm font-medium text-slate-700">Password</label>
            <Input 
              v-model="password" 
              type="password" 
              placeholder="Create a password" 
              class="w-full p-3 border rounded-md focus:ring-2 focus:ring-primary/20 focus:border-primary transition" 
              required 
              minlength="6" 
            />
            <p class="mt-2 text-sm text-slate-500">Password must be at least 6 characters long</p>
          </div>
          
          <Button 
            color="primary" 
            class="w-full py-3 font-medium text-white bg-primary hover:bg-primary-dark transition-colors" 
            :disabled="loading"
          >
            <span v-if="loading" class="flex items-center justify-center">
              <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              Creating account...
            </span>
            <span v-else>Create Account</span>
          </Button>
          
          <div class="mt-6 text-center text-sm">
            <RouterLink to="/" class="text-primary hover:text-primary-dark font-medium transition-colors">
              Already have an account? Sign in
            </RouterLink>
          </div>
        </form>
      </Card>
    </div>
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
    // Reset messages
    error.value = ''
    success.value = ''
    
    // Form validation
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
    
    console.log('Attempting to sign up with:', { email: email.value })
    
    // Sign up with Supabase
    const { data, error: signupError } = await supabase.auth.signUp({
      email: email.value,
      password: password.value,
      options: {
        // Add metadata with default role
        data: {
          role: 'staff'
        }
      }
    })
    
    // Handle response
    if (signupError) {
      console.error('Signup API error:', signupError)
      error.value = signupError.message || 'Failed to sign up'
    } else if (!data?.user) {
      console.error('No user returned from signup')
      error.value = 'No user created. Please try again.'
    } else {
      console.log('Signup successful, user created:', data.user.id)
      success.value = 'Account created successfully! Check your email to confirm your account.'
      
      // Clear form
      email.value = ''
      password.value = ''
      
      // Redirect to login after 3 seconds
      setTimeout(() => {
        router.push('/')
      }, 3000)
    }
  } catch (e) {
    console.error('Unexpected signup error:', e)
    error.value = 'An unexpected error occurred. Please try again later.'
  } finally {
    loading.value = false
  }
}
</script>
