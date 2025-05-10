<template>
  <div class="tabs flex border-b border-gray-200 mb-4">
    <button
      v-for="(tab, idx) in tabs"
      :key="tab.key || idx"
      :class="[
        'px-4 py-2 font-semibold transition-all min-w-[44px] min-h-[44px] outline-none',
        activeTab === idx ? 'border-b-4 border-primary text-primary bg-primary/5' : 'text-secondary hover:text-primary',
        'focus:ring-2 focus:ring-accent rounded-t-lg'
      ]"
      @click="setTab(idx)"
      type="button"
    >
      <span v-if="tab.icon" class="material-icons align-middle mr-1">{{ tab.icon }}</span>
      {{ tab.label }}
    </button>
  </div>
  <div class="tab-content">
    <slot :name="tabs[activeTab]?.slot || tabs[activeTab]?.key || activeTab" />
  </div>
</template>

<script setup lang="ts">
import { ref, watch, toRefs } from 'vue'
const props = defineProps({
  tabs: { type: Array, required: true },
  modelValue: { type: Number, default: 0 }
})
const emit = defineEmits(['update:modelValue'])
const activeTab = ref(props.modelValue)
watch(() => props.modelValue, v => { activeTab.value = v })
function setTab(idx: number) {
  activeTab.value = idx
  emit('update:modelValue', idx)
}
</script>

<style scoped>
.tabs button {
  border: none;
  background: none;
  cursor: pointer;
}
.tabs button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
