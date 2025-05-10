<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50">
    <Card class="w-full max-w-md">
      <h2 class="font-heading text-2xl mb-4 text-center">Sign Up</h2>
      <form @submit.prevent="onSignup">
        <Input v-model="email" type="email" placeholder="Email" class="mb-3" />
        <Input v-model="password" type="password" placeholder="Password" class="mb-4" />
        <Button color="primary" class="w-full mb-2" :disabled="loading">
          <span v-if="loading">Signing up...</span>
          <span v-else>Sign Up</span>
        </Button>
        <div class="flex justify-between text-sm mt-2">
          <a href="#" @click.prevent="$emit('login')" class="text-primary hover:underline">Already have an account?</a>
        </div>
      </form>
    </Card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import Card from '../components/Card.vue'
import Input from '../components/Input.vue'
import Button from '../components/Button.vue'

const email = ref('')
const password = ref('')
const loading = ref(false)

import { supabase } from '../supabase'
const error = ref('')
const success = ref('')

async function onSignup() {
  loading.value = true
  error.value = ''
  success.value = ''
  const { error: signupError } = await supabase.auth.signUp({
    email: email.value,
    password: password.value,
  })
  loading.value = false
  if (signupError) {
    error.value = signupError.message
  } else {
    success.value = 'Signup successful! Check your email to confirm your account.'
  }
}
</script>
