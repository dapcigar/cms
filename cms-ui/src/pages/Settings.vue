<template>
  <Layout>
    <h1 class="font-heading text-2xl mb-6">Settings</h1>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
      <Card class="p-6">
        <h2 class="font-heading text-xl mb-4">Profile Settings</h2>
        <form @submit.prevent="saveProfile" class="space-y-4">
          <div>
            <label class="block text-sm font-medium mb-1">Name</label>
            <Input v-model="profile.name" type="text" placeholder="Your name" />
          </div>
          <div>
            <label class="block text-sm font-medium mb-1">Email</label>
            <Input v-model="profile.email" type="email" placeholder="Your email" />
          </div>
          <div>
            <label class="block text-sm font-medium mb-1">Role</label>
            <Input v-model="profile.role" type="text" disabled />
          </div>
          <Button color="primary" type="submit">Save Changes</Button>
        </form>
      </Card>

      <Card class="p-6">
        <h2 class="font-heading text-xl mb-4">Notification Preferences</h2>
        <div class="space-y-4">
          <div class="flex items-center justify-between">
            <div>
              <h3 class="font-medium">Email Notifications</h3>
              <p class="text-sm text-gray-600">Receive notifications via email</p>
            </div>
            <Toggle v-model="notifications.email" />
          </div>
          <div class="flex items-center justify-between">
            <div>
              <h3 class="font-medium">Push Notifications</h3>
              <p class="text-sm text-gray-600">Receive browser notifications</p>
            </div>
            <Toggle v-model="notifications.push" />
          </div>
          <Button color="primary" @click="saveNotifications">Save Preferences</Button>
        </div>
      </Card>
    </div>
  </Layout>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import Layout from '../components/Layout.vue'
import Card from '../components/Card.vue'
import Input from '../components/Input.vue'
import Button from '../components/Button.vue'
import Toggle from '../components/Toggle.vue'

const profile = ref({
  name: 'John Doe',
  email: 'john@example.com',
  role: 'Administrator'
})

const notifications = ref({
  email: true,
  push: false
})

async function saveProfile() {
  // TODO: Implement profile update
  console.log('Saving profile:', profile.value)
}

async function saveNotifications() {
  // TODO: Implement notification preferences update
  console.log('Saving notification preferences:', notifications.value)
}
</script>
