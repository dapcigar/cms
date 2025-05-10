<template>
  <div class="fixed top-20 right-6 w-80 z-50">
    <div class="bg-white rounded-lg shadow-lg overflow-hidden">
      <div class="bg-primary text-white px-4 py-2 font-heading text-lg flex justify-between items-center">
        <span>Notifications</span>
        <button @click="$emit('close')" class="text-white hover:text-gray-200">&times;</button>
      </div>
      <div v-if="notifications.length === 0" class="p-4 text-gray-500">No notifications</div>
      <ul v-else class="divide-y divide-gray-200">
        <li v-for="n in notifications" :key="n.id" class="p-4 hover:bg-gray-50">
          <div class="font-semibold">{{ n.title }}</div>
          <div class="text-sm text-gray-700">{{ n.message }}</div>
          <div class="text-xs text-gray-400 mt-1">{{ formatDate(n.created_at) }}</div>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { supabase } from '../supabase'

const notifications = ref<any[]>([])
let subscription: any = null

function formatDate(date: string) {
  return new Date(date).toLocaleString()
}

async function fetchNotifications(userId: string) {
  const { data } = await supabase.from('notifications').select('*').eq('user_id', userId).order('created_at', { ascending: false })
  notifications.value = data || []
}

function subscribeToNotifications(userId: string) {
  subscription = supabase
    .channel('notifications')
    .on('postgres_changes', { event: '*', schema: 'public', table: 'notifications', filter: `user_id=eq.${userId}` }, payload => {
      fetchNotifications(userId)
    })
    .subscribe()
}

function unsubscribe() {
  if (subscription) {
    supabase.removeChannel(subscription)
    subscription = null
  }
}

onUnmounted(unsubscribe)

// Usage: parent must call fetchNotifications and subscribeToNotifications with userId
</script>

<style scoped>
</style>
