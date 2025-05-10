<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50">
    <Card class="w-full max-w-md">
      <h2 class="font-heading text-2xl mb-4 text-center">Reset Password</h2>
      <form @submit.prevent="onReset">
        <Input v-model="email" type="email" placeholder="Email" class="mb-3" />
        <Button color="primary" class="w-full mb-2" :disabled="loading">
          <span v-if="loading">Sending...</span>
          <span v-else>Send Reset Link</span>
        </Button>
        <div class="flex justify-between text-sm mt-2">
          <a href="#" @click.prevent="$emit('login')" class="text-primary hover:underline">Back to login</a>
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
const loading = ref(false)

import { supabase } from '../supabase'
const error = ref('')
const success = ref('')

async function onReset() {
  loading.value = true
  error.value = ''
  success.value = ''
  const { error: resetError } = await supabase.auth.resetPasswordForEmail(email.value)
  loading.value = false
  if (resetError) {
    error.value = resetError.message
  } else {
    success.value = 'Password reset email sent! Check your inbox.'
  }
}
</script>
