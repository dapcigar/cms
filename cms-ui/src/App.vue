<script setup lang="ts">
// Global app component
</script>

<template>
  <div class="app-container">
    <router-view />
  </div>
</template>

<style>
/* Global Styles */
:root {
  --color-primary: #0070F3;
  --color-accent: #FF7A59;
  --color-background: #F9FAFB;
  --color-text: #1F2937;
  --color-success: #10B981;
  --color-error: #EF4444;
  --color-info: #3B82F6;
}

/* Base Styles */
html, body {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  color: var(--color-text);
  background-color: var(--color-background);
  margin: 0;
  padding: 0;
  height: 100%;
  width: 100%;
}

body {
  line-height: 1.5;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#app, .app-container {
  height: 100%;
  width: 100%;
}

/* Components */
.card {
  background-color: white;
  border-radius: 0.5rem;
  padding: 1.5rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

/* Buttons */
button, .btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0.5rem 1rem;
  font-weight: 500;
  font-size: 0.875rem;
  border-radius: 0.375rem;
  transition: all 0.2s ease;
  border: none;
  cursor: pointer;
  min-height: 42px; /* Larger touch targets */
}

.btn-primary {
  background-color: var(--color-primary);
  color: white;
}

.btn-primary:hover {
  background-color: rgba(0, 112, 243, 0.9);
}

.btn-accent {
  background-color: var(--color-accent);
  color: white;
}

/* Form Elements */
input, select, textarea {
  width: 100%;
  padding: 0.625rem 0.75rem;
  border-radius: 0.375rem;
  border: 1px solid #D1D5DB;
  background-color: white;
  font-size: 0.875rem;
  transition: all 0.2s ease;
  min-height: 42px; /* Larger touch targets */
}

input:focus, select:focus, textarea:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(0, 112, 243, 0.1);
}

/* Table Styles */
table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
}

th {
  text-align: left;
  padding: 1rem;
  background-color: var(--color-background);
  font-weight: 500;
  color: var(--color-text);
  border-bottom: 1px solid #E5E7EB;
}

td {
  padding: 1rem;
  border-bottom: 1px solid #E5E7EB;
}

/* Status Indicators */
.status {
  display: inline-flex;
  align-items: center;
  padding: 0.25rem 0.75rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 500;
}

.status-open {
  background-color: rgba(0, 112, 243, 0.1);
  color: var(--color-primary);
}

.status-closed {
  background-color: rgba(16, 185, 129, 0.1);
  color: var(--color-success);
}

/* Transitions */
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from, .fade-leave-to {
  opacity: 0;
}

/* Layout Components */
.sidebar {
  width: 240px;
  background-color: white;
  border-right: 1px solid #E5E7EB;
  height: 100vh;
  position: fixed;
  left: 0;
  top: 0;
  z-index: 10;
  transition: all 0.3s ease;
}

.sidebar-collapsed {
  width: 60px;
}

.main-content {
  margin-left: 240px;
  padding: 1.5rem;
  transition: all 0.3s ease;
}

.main-content-expanded {
  margin-left: 60px;
}
</style>
