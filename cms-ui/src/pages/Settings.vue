<template>
  <Layout>
    <h1 class="font-heading text-2xl mb-6">Settings</h1>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
      <Card type="primary" class="settings-card">
        <h2 class="settings-title">Profile Settings</h2>
        <form @submit.prevent="saveProfile" class="settings-form">
          <div class="form-group">
            <label class="form-label">Name</label>
            <Input v-model="profile.name" type="text" placeholder="Your name" class="form-input" />
          </div>
          <div class="form-group">
            <label class="form-label">Email</label>
            <Input v-model="profile.email" type="email" placeholder="Your email" class="form-input" />
          </div>
          <div class="form-group">
            <label class="form-label">Role</label>
            <Input v-model="profile.role" type="text" disabled class="form-input" />
          </div>
          <Button color="primary" type="submit" class="mt-4">Save Changes</Button>
        </form>
      </Card>

      <Card type="accent" class="settings-card">
        <h2 class="settings-title">Notification Preferences</h2>
        <div class="settings-form">
          <div class="toggle-item">
            <div>
              <h3 class="toggle-title">Email Notifications</h3>
              <p class="toggle-description">Receive notifications via email</p>
            </div>
            <Toggle v-model="notifications.email" />
          </div>
          <div class="toggle-item">
            <div>
              <h3 class="toggle-title">Push Notifications</h3>
              <p class="toggle-description">Receive browser notifications</p>
            </div>
            <Toggle v-model="notifications.push" />
          </div>
          <Button color="accent" @click="saveNotifications" class="mt-4">Save Preferences</Button>
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

<style scoped>
.settings-card {
  padding: 1.5rem;
  transition: all 0.2s ease;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.settings-title {
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--color-text);
  margin-bottom: 1.25rem;
  padding-bottom: 0.75rem;
  border-bottom: 1px solid #E5E7EB;
}

.settings-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
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
  padding: 0.625rem 0.75rem;
  border: 1px solid #E5E7EB;
  border-radius: 0.375rem;
  transition: all 0.2s ease;
}

.form-input:focus {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 2px rgba(0, 112, 243, 0.2);
}

.toggle-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.75rem 0;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
}

.toggle-item:last-of-type {
  border-bottom: none;
  margin-bottom: 0.5rem;
}

.toggle-title {
  font-size: 1rem;
  font-weight: 500;
  color: var(--color-text);
  margin-bottom: 0.25rem;
}

.toggle-description {
  font-size: 0.875rem;
  color: rgba(31, 41, 55, 0.7);
}
</style>
