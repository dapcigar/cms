<template>
  <aside class="h-full w-64 bg-white border-r border-gray-200 flex flex-col py-6 px-4 shadow-lg">
    <nav class="flex-1">
      <ul class="space-y-2">
        <li v-for="item in navItems" :key="item.label">
          <a :href="item.href" class="flex items-center px-3 py-2 rounded hover:bg-primary hover:text-white transition">
            <span class="material-icons mr-2">{{ item.icon }}</span>
            {{ item.label }}
          </a>
        </li>
      </ul>
    </nav>
  </aside>
</template>

<script setup lang="ts">
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
</script>
