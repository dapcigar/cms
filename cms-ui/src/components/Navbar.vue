<template>
  <nav class="flex items-center justify-between px-4 sm:px-8 py-4 bg-white text-slate-800 border-b border-gray-200 shadow-sm font-sans transition-all sticky top-0 z-50">
    <div class="flex items-center gap-3">
      <!-- Hamburger for mobile -->
      <button @click="$emit('toggle-sidebar')" class="md:hidden p-2 rounded-lg hover:bg-primary/10 hover:text-primary focus:outline-none transition-all min-w-[44px] min-h-[44px]" aria-label="Open menu">
        <svg class="w-7 h-7" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16"/></svg>
      </button>
      <div class="font-heading text-xl md:text-2xl font-bold tracking-tight ml-2 text-primary">Care Management System</div>
    </div>
    <div class="flex items-center gap-4">
      <slot name="actions" />
      <button class="relative rounded-full hover:bg-primary/10 text-slate-800 hover:text-primary transition-all focus:outline-none min-w-[44px] min-h-[44px] flex items-center justify-center" aria-label="Notifications">
        <span class="material-icons text-2xl">notifications</span>
        <span class="absolute -top-1 -right-1 bg-accent text-white rounded-full px-1.5 py-0.5 text-xs font-bold">3</span>
      </button>
      <button class="rounded-full hover:bg-primary/10 text-slate-800 hover:text-primary transition-all focus:outline-none min-w-[44px] min-h-[44px] flex items-center justify-center" aria-label="Settings">
        <span class="material-icons text-2xl">settings</span>
      </button>
      <button class="rounded-full bg-primary text-white px-4 py-2 hover:bg-primary/90 transition-all focus:outline-none min-w-[44px] min-h-[44px] font-semibold flex items-center gap-2">
        <span class="material-icons">account_circle</span>
        <span>Profile</span>
      </button>
    </div>
  </nav>
</template>

<script setup lang="ts">
// Emits: toggle-sidebar
</script>
