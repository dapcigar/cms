<template>
  <div class="min-h-screen flex flex-col">
    <Navbar @toggle-sidebar="showSidebar = !showSidebar" />
    <div class="flex flex-1">
      <!-- Desktop Sidebar -->
      <Sidebar class="hidden md:block" />
      <!-- Mobile Sidebar Drawer -->
      <transition name="slide">
        <Sidebar v-if="showSidebar" class="fixed inset-0 z-40 bg-white shadow-lg md:hidden transition-all duration-300" @close="showSidebar = false" />
      </transition>
      <main class="flex-1 bg-gray-50 p-4 sm:p-6 overflow-y-auto">
        <slot />
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import Navbar from './Navbar.vue'
import Sidebar from './Sidebar.vue'
const showSidebar = ref(false)
</script>

<style scoped>
.slide-enter-active, .slide-leave-active {
  transition: transform 0.3s;
}
.slide-enter-from, .slide-leave-to {
  transform: translateX(-100%);
}
</style>
