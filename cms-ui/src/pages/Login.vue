<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50">
    <Card class="w-full max-w-md">
      <h2 class="font-heading text-2xl mb-4 text-center">Sign In</h2>
      <form @submit.prevent="onLogin">
        <Input v-model="email" type="email" placeholder="Email" class="mb-3" />
        <Input v-model="password" type="password" placeholder="Password" class="mb-4" />
        <Button color="primary" class="w-full mb-2" :disabled="loading">
          <span v-if="loading">Signing in...</span>
          <span v-else>Sign In</span>
        </Button>
        <div class="flex justify-between text-sm mt-2">
          <a href="#" @click.prevent="$emit('forgot')" class="text-primary hover:underline">Forgot password?</a>
          <a href="#" @click.prevent="$emit('signup')" class="text-primary hover:underline">Sign up</a>
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

async function onLogin() {
  loading.value = true
  error.value = ''
  const { error: loginError } = await supabase.auth.signInWithPassword({
    email: email.value,
    password: password.value,
  })
  loading.value = false
  if (loginError) {
    error.value = loginError.message
  } else {
    // TODO: Redirect to dashboard or home
  }
}
</script>
