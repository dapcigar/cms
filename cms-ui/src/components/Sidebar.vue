<template>
  <Transition name="slide">
    <aside
      :class="[
        'h-full flex flex-col py-6 px-3 shadow-lg transition-all duration-300',
        'bg-surface border-r border-gray-200',
        collapsed ? 'w-20' : 'w-64',
        'fixed md:relative z-40'
      ]"
    >
    <nav class="flex-1">
      <ul class="space-y-2">
        <li v-for="item in navItems" :key="item.label">
          <a
            :href="item.href"
            class="flex items-center px-3 py-3 rounded-xl transition-all hover:bg-primary/10 hover:text-primary"
            :class="{
              'bg-primary text-white': isActive(item),
              'text-primary': !isActive(item)
            }"
          >
            <span class="material-icons mr-2 text-2xl" :class="collapsed ? 'mx-auto' : ''">{{ item.icon }}</span>
            <span v-if="!collapsed" class="ml-1">{{ item.label }}</span>
            <span v-if="item.label === 'Notifications'" class="ml-2 bg-accent text-white rounded-full px-2 py-0.5 text-xs font-bold" v-if="!collapsed">3</span>
          </a>
        </li>
      </ul>
    </nav>
    <button
      class="mt-4 mb-2 mx-auto flex items-center justify-center p-2 rounded-full bg-primary/10 text-primary hover:bg-primary hover:text-white transition-all"
      @click="toggleCollapse"
      :aria-label="collapsed ? 'Expand sidebar' : 'Collapse sidebar'"
    >
      <span class="material-icons">{{ collapsed ? 'chevron_right' : 'chevron_left' }}</span>
    </button>
      </aside>
  </Transition>
</template>

<script setup lang="ts">
import { ref } from 'vue'
const collapsed = ref(false)
const navItems = [
  { label: 'Dashboard', href: '#', icon: 'dashboard' },
  { label: 'Users & Roles', href: '#', icon: 'people' },
  { label: 'Audits', href: '#', icon: 'assignment' },
  { label: 'Action Plans', href: '#', icon: 'check_circle' },
  { label: 'Safeguarding', href: '#', icon: 'security' },
  { label: 'Incidents', href: '#', icon: 'report' },
  { label: 'Surveys', href: '#', icon: 'poll' },
  { label: 'Analytics', href: '#', icon: 'insights' },
  { label: 'Notifications', href: '#', icon: 'notifications' },
  { label: 'Settings', href: '#', icon: 'settings' },
];
function toggleCollapse() {
  collapsed.value = !collapsed.value
}
function isActive(item) {
  // Replace with real route check if using Vue Router
  return window.location.hash === item.href
}
</script>

<style scoped>
.slide-enter-active,
.slide-leave-active {
  transition: transform 0.3s ease;
}

.slide-enter-from,
.slide-leave-to {
  transform: translateX(-100%);
}

@media (max-width: 768px) {
  aside {
    position: fixed;
    left: 0;
    top: 0;
    height: 100vh;
    z-index: 50;
    box-shadow: 2px 0 8px rgba(0,0,0,0.07);
  }
}
</style>
