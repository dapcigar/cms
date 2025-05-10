<template>
  <div class="app-layout">
    <Navbar @toggle-sidebar="toggleSidebar" :collapsed="sidebarCollapsed" />
    <div class="layout-container">
      <!-- Desktop Sidebar - Collapsible -->
      <Sidebar 
        class="desktop-sidebar" 
        :class="{'sidebar-collapsed': sidebarCollapsed}"
        :collapsed="sidebarCollapsed"
        @toggle-collapse="toggleSidebar" 
      />
      
      <!-- Mobile Sidebar Backdrop -->
      <Transition name="fade">
        <div 
          v-if="showMobileSidebar" 
          class="sidebar-backdrop" 
          @click="closeMobileSidebar">
        </div>
      </Transition>
      
      <!-- Mobile Sidebar Drawer -->
      <Transition name="slide">
        <Sidebar 
          v-if="showMobileSidebar" 
          class="mobile-sidebar" 
          @close="closeMobileSidebar" 
        />
      </Transition>
      
      <main 
        class="main-content" 
        :class="{'main-content-expanded': sidebarCollapsed}">
        <slot />
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import Navbar from './Navbar.vue'
import Sidebar from './Sidebar.vue'

const showMobileSidebar = ref(false)
const sidebarCollapsed = ref(false)

function toggleSidebar() {
  // On mobile, toggle visibility
  if (window.innerWidth < 768) {
    showMobileSidebar.value = !showMobileSidebar.value
  } else {
    // On desktop, toggle collapse state
    sidebarCollapsed.value = !sidebarCollapsed.value
  }
}

function closeMobileSidebar() {
  showMobileSidebar.value = false
}
</script>

<style scoped>
/* Layout structure */
.app-layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.layout-container {
  display: flex;
  flex: 1;
}

/* Sidebar styles */
.desktop-sidebar {
  width: 240px;
  background-color: white;
  border-right: 1px solid #E5E7EB;
  height: 100vh;
  position: fixed;
  left: 0;
  top: 64px; /* Height of navbar */
  bottom: 0;
  z-index: 10;
  transition: all 0.3s ease;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
  display: none;
}

@media (min-width: 768px) {
  .desktop-sidebar {
    display: block;
  }
}

.sidebar-collapsed {
  width: 64px;
}

.mobile-sidebar {
  position: fixed;
  top: 64px; /* Height of navbar */
  left: 0;
  bottom: 0;
  width: 240px;
  z-index: 40;
  background-color: white;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.sidebar-backdrop {
  position: fixed;
  inset: 0;
  background-color: rgba(31, 41, 55, 0.5); /* Text color with opacity */
  z-index: 30;
  display: none;
}

@media (max-width: 767px) {
  .sidebar-backdrop {
    display: block;
  }
}

/* Main content area */
.main-content {
  flex: 1;
  background-color: #F9FAFB; /* Background color from design system */
  padding: 1.5rem;
  overflow-y: auto;
  margin-left: 240px;
  transition: margin-left 0.3s ease;
}

.main-content-expanded {
  margin-left: 64px;
}

@media (max-width: 767px) {
  .main-content {
    margin-left: 0;
  }
}

/* Transitions */
.slide-enter-active,
.slide-leave-active {
  transition: transform 0.3s ease-in-out;
}

.slide-enter-from,
.slide-leave-to {
  transform: translateX(-100%);
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
