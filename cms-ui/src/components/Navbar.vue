<template>
  <header class="app-header">
    <div class="header-left">
      <!-- Toggle button - changes icon based on collapsed state -->
      <button @click="$emit('toggle-sidebar')" class="toggle-button" :aria-label="collapsed ? 'Expand sidebar' : 'Collapse sidebar'">
        <svg v-if="!collapsed || isMobile" class="icon-menu" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16"/>
        </svg>
        <svg v-else class="icon-menu" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" d="M13 5l7 7-7 7M5 5l7 7-7 7"/>
        </svg>
      </button>
      
      <!-- App Title -->
      <div class="app-title">Care Management System</div>
    </div>
    
    <div class="header-right">
      <slot name="actions" />
      
      <!-- Notifications -->
      <button class="icon-button notification-button">
        <span class="material-icons">notifications</span>
        <span class="notification-badge">3</span>
      </button>
      
      <!-- Settings -->
      <button class="icon-button">
        <span class="material-icons">settings</span>
      </button>
      
      <!-- Profile -->
      <button class="profile-button">
        <span class="material-icons">account_circle</span>
        <span>Profile</span>
      </button>
    </div>
  </header>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'

// Props
const props = defineProps({
  collapsed: {
    type: Boolean,
    default: false
  }
})

// Emit events
const emit = defineEmits(['toggle-sidebar'])

// Detect if on mobile
const isMobile = ref(window.innerWidth < 768)

// Handle window resize
function handleResize() {
  isMobile.value = window.innerWidth < 768
}

onMounted(() => {
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
})
</script>

<style scoped>
.app-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 64px;
  padding: 0 1.5rem;
  background-color: white;
  border-bottom: 1px solid #E5E7EB;
  position: sticky;
  top: 0;
  z-index: 50;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.toggle-button {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 42px;
  height: 42px;
  border-radius: 0.375rem;
  color: var(--color-text);
  transition: all 0.2s ease;
  border: none;
  background: transparent;
  cursor: pointer;
}

.toggle-button:hover {
  background-color: rgba(0, 112, 243, 0.1);
  color: var(--color-primary);
}

.icon-menu {
  width: 24px;
  height: 24px;
}

.app-title {
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--color-primary);
  margin-left: 0.5rem;
}

@media (min-width: 768px) {
  .app-title {
    font-size: 1.5rem;
  }
}

.icon-button {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 42px;
  height: 42px;
  border-radius: 9999px;
  color: var(--color-text);
  transition: all 0.2s ease;
  border: none;
  background: transparent;
  cursor: pointer;
  position: relative;
}

.icon-button:hover {
  background-color: rgba(0, 112, 243, 0.1);
  color: var(--color-primary);
}

.notification-button {
  position: relative;
}

.notification-badge {
  position: absolute;
  top: 5px;
  right: 5px;
  background-color: var(--color-accent);
  color: white;
  border-radius: 9999px;
  padding: 0.125rem 0.375rem;
  font-size: 0.75rem;
  font-weight: 600;
  min-width: 1.25rem;
  text-align: center;
}

.profile-button {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  border-radius: 9999px;
  background-color: var(--color-primary);
  color: white;
  transition: all 0.2s ease;
  border: none;
  font-weight: 500;
  cursor: pointer;
}

.profile-button:hover {
  background-color: rgba(0, 112, 243, 0.9);
}
</style>
