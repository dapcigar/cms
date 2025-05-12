<template>
  <div
    class="template-card bg-white border border-[#E5E7EB] rounded-lg overflow-hidden hover:shadow-md transition-all duration-200"
    :class="{ 'cursor-pointer hover:shadow-lg transition-shadow duration-200': clickable }"
    tabindex="0"
    @click.stop="handleClick"
    @keydown.enter="handleClick"
    aria-label="View Audit Template Details"
  >
    <div class="p-6" @click.stop>
      <div class="flex justify-between items-start gap-4">
        <h3 class="font-semibold text-lg text-[#1F2937]">{{ template.title }}</h3>
        <span 
          class="px-3 py-1 text-xs font-medium rounded-full"
          :style="badgeStyle"
        >
          {{ template.frequency.charAt(0).toUpperCase() + template.frequency.slice(1) }}
        </span>
      </div>
      <div class="mt-3 text-sm text-[#6B7280]">
        Created: {{ formatDate(template.created_at) }}
      </div>
      <div class="mt-6 flex space-x-3">
        <button 
          @click.stop="$emit('edit', template)"
          class="text-sm font-medium text-[#0070F3] hover:text-[#005CC5] px-4 py-2 rounded-md focus:outline-none focus:ring-2 focus:ring-[#0070F3] focus:ring-offset-2 transition-colors"
        >
          Edit
        </button>
        <button 
          @click.stop="$emit('delete', template.id)"
          class="text-sm font-medium text-[#EF4444] hover:text-[#DC2626] px-4 py-2 rounded-md focus:outline-none focus:ring-2 focus:ring-[#EF4444] focus:ring-offset-2 transition-colors"
        >
          Delete
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps({
  template: {
    type: Object,
    required: true
  },
  clickable: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['detail', 'edit', 'delete', 'click'])

const badgeStyle = computed(() => {
  switch (props.template.frequency) {
    case 'daily':
      return 'background-color: #E0F2FE; color: #0070F3;';
    case 'weekly':
      return 'background-color: #FFE4D9; color: #FF7A59;';
    case 'monthly':
      return 'background-color: #D1FAE5; color: #10B981;';
    default:
      return 'background-color: #F3F4F6; color: #1F2937;';
  }
})

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString()
}

function handleCardClick(event: MouseEvent) {
  // Only emit detail if the click is not on a button
  const target = event.target as HTMLElement
  if (!target.closest('button')) {
    emit('detail', props.template)
  }
}

function handleClick() {
  if (props.clickable) {
    emit('click', props.template)
  }
}
</script>

<style scoped>
.template-card {
  @apply bg-white;
  min-height: 180px;
}

.template-card > * {
  pointer-events: none;
}
</style>
