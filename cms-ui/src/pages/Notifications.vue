<template>
  <Layout>
    <h1 class="font-heading text-2xl mb-6">Notifications</h1>
    <div class="space-y-4">
      <Card v-for="notification in notifications" :key="notification.id" class="p-4">
        <div class="flex items-start gap-4">
          <span class="material-icons text-accent">{{ notification.icon }}</span>
          <div class="flex-1">
            <h3 class="font-semibold text-lg">{{ notification.title }}</h3>
            <p class="text-gray-600">{{ notification.message }}</p>
            <span class="text-sm text-gray-500">{{ notification.time }}</span>
          </div>
          <button @click="markAsRead(notification.id)" class="text-primary hover:text-primary/80">
            <span class="material-icons">check_circle</span>
          </button>
        </div>
      </Card>
    </div>
  </Layout>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import Layout from '../components/Layout.vue'
import Card from '../components/Card.vue'

const notifications = ref([
  {
    id: 1,
    icon: 'assignment',
    title: 'New Audit Assigned',
    message: 'You have been assigned to conduct an audit for Care Home A.',
    time: '2 hours ago'
  },
  {
    id: 2,
    icon: 'report',
    title: 'Incident Report Update',
    message: 'The incident report #123 has been updated with new information.',
    time: '5 hours ago'
  },
  {
    id: 3,
    icon: 'security',
    title: 'Safeguarding Alert',
    message: 'A new safeguarding concern has been raised.',
    time: '1 day ago'
  }
])

function markAsRead(id: number) {
  notifications.value = notifications.value.filter(n => n.id !== id)
}
</script>
