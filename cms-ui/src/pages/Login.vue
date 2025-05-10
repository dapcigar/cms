<template>
  <div class="login-container">
    <Card type="primary" class="login-card">
      <h2 class="login-title">Sign In</h2>
      <form @submit.prevent="onLogin" class="login-form">
        <div v-if="error" class="login-error">
          {{ error }}
        </div>
        <div class="form-group">
          <Input 
            v-model="email" 
            type="email" 
            placeholder="Email" 
            class="form-input" 
            required 
          />
        </div>
        <div class="form-group">
          <Input 
            v-model="password" 
            type="password" 
            placeholder="Password" 
            class="form-input" 
            required 
            minlength="6" 
          />
        </div>
        <Button color="primary" class="login-button" :disabled="loading">
          <span v-if="loading">Signing in...</span>
          <span v-else>Sign In</span>
        </Button>
        <div class="login-links">
          <RouterLink to="/forgot-password" class="login-link">Forgot password?</RouterLink>
          <RouterLink to="/signup" class="login-link">Sign up</RouterLink>
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

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: var(--color-background);
  padding: 1rem;
}

.login-card {
  width: 100%;
  max-width: 440px;
  padding: 2rem;
  border-radius: 0.75rem;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.05);
  background-color: white;
  border-top: 4px solid var(--color-primary);
}

.login-title {
  font-size: 1.75rem;
  font-weight: 600;
  color: var(--color-text);
  margin-bottom: 1.5rem;
  text-align: center;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.form-group {
  margin-bottom: 0.5rem;
}

.form-input {
  width: 100%;
  transition: all 0.2s ease;
}

.login-error {
  margin-bottom: 1rem;
  padding: 0.75rem 1rem;
  border-radius: 0.5rem;
  background-color: rgba(239, 68, 68, 0.1);
  color: var(--color-error);
  font-size: 0.875rem;
}

.login-button {
  width: 100%;
  padding: 0.75rem 1rem;
  margin-top: 0.5rem;
  font-weight: 500;
  transition: all 0.2s ease;
}

.login-links {
  display: flex;
  justify-content: space-between;
  margin-top: 1rem;
  font-size: 0.875rem;
}

.login-link {
  color: var(--color-primary);
  text-decoration: none;
  transition: all 0.2s ease;
}

.login-link:hover {
  text-decoration: underline;
}
</style>
