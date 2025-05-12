<template>
  <div class="flex flex-col items-center justify-center min-h-[70vh] px-4">
    <div class="text-[#FF7A59] text-6xl mb-6">
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="w-24 h-24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
      </svg>
    </div>
    <h1 class="text-3xl font-bold text-[#1F2937] mb-2">Access Denied</h1>
    <p class="text-lg text-gray-600 mb-8 text-center">
      You don't have permission to access this page.
    </p>
    <div class="space-x-4">
      <button 
        @click="goBack" 
        class="px-6 py-2 bg-[#0070F3] text-white rounded-md hover:bg-blue-600 transition-colors"
      >
        Go Back
      </button>
      <button 
        @click="goHome" 
        class="px-6 py-2 border border-gray-300 text-[#1F2937] rounded-md hover:bg-gray-50 transition-colors"
      >
        Go to Home
      </button>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router';

const router = useRouter();

function goBack() {
  router.go(-1);
}

function goHome() {
  router.push('/');
}
</script>
