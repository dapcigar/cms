<template>
  <aside class="sidebar" :class="{'sidebar-collapsed': collapsed}">
    <nav class="sidebar-nav">
      <ul class="nav-list">
        <li v-for="item in navItems" :key="item.path" class="nav-item">
          <a
            href="#"
            @click.prevent="navigateTo(item.path)"
            class="nav-link"
            :class="{
              'active': isActive(item),
              'collapsed-item': collapsed
            }"
          >
            <span class="nav-icon material-icons">{{ item.icon }}</span>
            <span v-if="!collapsed" class="nav-label">{{ item.label }}</span>
            <span 
              v-if="!collapsed && item.label === 'Notifications'" 
              class="nav-badge"
            >3</span>
          </a>
        </li>
        <li class="nav-item">
          <a
            href="#"
            @click.prevent="navigateTo('/audits')"
            class="nav-link"
            :class="{
              'active': isActive({path: '/audits'}),
              'collapsed-item': collapsed
            }"
          >
            <span class="nav-icon material-icons">checklist</span>
            <span v-if="!collapsed" class="nav-label">Audits</span>
          </a>
        </li>
      </ul>
    </nav>
    
    <!-- Collapse toggle button -->
    <button
      v-if="!isMobile"
      class="collapse-button"
      @click="toggleCollapse"
      :aria-label="collapsed ? 'Expand sidebar' : 'Collapse sidebar'"
    >
      <span class="material-icons">{{ collapsed ? 'chevron_right' : 'chevron_left' }}</span>
    </button>
    
    <!-- Close button for mobile -->
    <button
      v-if="isMobile"
      class="close-button"
      @click="$emit('close')"
      aria-label="Close menu"
    >
      <span class="material-icons">close</span>
    </button>
  </aside>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'

// Props
const props = defineProps({
  collapsed: {
    type: Boolean,
    default: false
  }
})

// Emits
const emit = defineEmits(['toggle-collapse', 'close'])

const route = useRoute()
const router = useRouter()

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

const navItems = [
  { label: 'Dashboard', path: '/dashboard', icon: 'dashboard' },
  { label: 'Users & Roles', path: '/users', icon: 'people' },
  { label: 'Audits', path: '/audits', icon: 'assignment' },
  { label: 'Action Plans', path: '/action-plans', icon: 'check_circle' },
  { label: 'Safeguarding', path: '/safeguarding', icon: 'security' },
  { label: 'Incidents', path: '/incidents', icon: 'report' },
  { label: 'Surveys', path: '/surveys', icon: 'poll' },
  { label: 'Analytics', path: '/analytics', icon: 'insights' },
  { label: 'Notifications', path: '/notifications', icon: 'notifications' },
  { label: 'Settings', path: '/settings', icon: 'settings' },
]

function toggleCollapse() {
  emit('toggle-collapse')
}

function isActive(item) {
  return route.path === item.path
}

function navigateTo(path: string) {
  router.push(path)
  
  // Close sidebar on mobile after navigation
  if (isMobile.value) {
    emit('close')
  }
}
</script>

<style scoped>
.sidebar {
  display: flex;
  flex-direction: column;
  height: 100%;
  background-color: white;
  border-right: 1px solid #E5E7EB;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
  width: 240px;
  overflow-x: hidden;
  overflow-y: auto;
  position: relative;
  padding: 1.5rem 0.75rem;
}

.sidebar-collapsed {
  width: 64px;
}

.sidebar-nav {
  flex: 1;
  margin-top: 0.5rem;
}

.nav-list {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.nav-item {
  width: 100%;
}

.nav-link {
  display: flex;
  align-items: center;
  padding: 0.75rem 1rem;
  border-radius: 0.5rem;
  color: var(--color-text);
  text-decoration: none;
  transition: all 0.2s ease;
  min-height: 48px; /* Larger touch target */
  position: relative;
  overflow: hidden;
}

.nav-link:hover {
  background-color: rgba(0, 112, 243, 0.1);
  color: var(--color-primary);
}

.nav-link.active {
  background-color: var(--color-primary);
  color: white;
}

.nav-icon {
  font-size: 1.5rem;
  min-width: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.nav-label {
  margin-left: 0.75rem;
  font-size: 0.9375rem;
  font-weight: 500;
  white-space: nowrap;
}

.nav-badge {
  margin-left: 0.5rem;
  background-color: var(--color-accent);
  color: white;
  border-radius: 9999px;
  padding: 0.125rem 0.375rem;
  font-size: 0.75rem;
  font-weight: 600;
  min-width: 1.25rem;
  text-align: center;
}

.collapsed-item {
  justify-content: center;
  padding: 0.75rem;
}

.collapse-button {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background-color: rgba(0, 112, 243, 0.1);
  color: var(--color-primary);
  margin: 1rem auto 0.5rem auto;
  border: none;
  cursor: pointer;
  transition: all 0.2s ease;
}

.collapse-button:hover {
  background-color: var(--color-primary);
  color: white;
}

.close-button {
  position: absolute;
  top: 0.75rem;
  right: 0.75rem;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  border: none;
  background-color: transparent;
  color: var(--color-text);
  cursor: pointer;
  transition: all 0.2s ease;
}

.close-button:hover {
  background-color: rgba(0, 0, 0, 0.05);
}
</style>
