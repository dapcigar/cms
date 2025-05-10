<template>
  <div class="max-w-xl mx-auto bg-white rounded-lg shadow-lg p-6">
    <div class="flex items-center mb-6">
      <div v-for="(step, idx) in steps" :key="idx" class="flex-1 flex flex-col items-center">
        <div :class="['rounded-full w-10 h-10 flex items-center justify-center font-bold text-lg',
          idx < currentStep ? 'bg-success text-white' : (idx === currentStep ? 'bg-primary text-white' : 'bg-gray-200 text-gray-400')
        ]">{{ idx + 1 }}</div>
        <div class="mt-2 text-xs text-center" :class="idx === currentStep ? 'text-primary font-semibold' : 'text-gray-400'">
          {{ step.label }}
        </div>
        <div v-if="idx < steps.length - 1" class="h-1 w-full bg-gray-200 mt-2 mb-2"></div>
      </div>
    </div>
    <form @submit.prevent="nextStep">
      <slot :step="currentStep" :goToStep="goToStep" :isLast="currentStep === steps.length - 1" />
      <div class="flex justify-between mt-6">
        <Button color="secondary" :disabled="currentStep === 0" @click.prevent="prevStep">Back</Button>
        <Button color="primary" type="submit">{{ currentStep === steps.length - 1 ? 'Finish' : 'Next' }}</Button>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import Button from './Button.vue'
const props = defineProps({
  steps: { type: Array, required: true },
  modelValue: { type: Number, default: 0 }
})
const emit = defineEmits(['update:modelValue', 'finish'])
const currentStep = ref(props.modelValue)
function nextStep() {
  if (currentStep.value < props.steps.length - 1) {
    currentStep.value++
    emit('update:modelValue', currentStep.value)
  } else {
    emit('finish')
  }
}
function prevStep() {
  if (currentStep.value > 0) {
    currentStep.value--
    emit('update:modelValue', currentStep.value)
  }
}
function goToStep(step: number) {
  if (step >= 0 && step < props.steps.length) {
    currentStep.value = step
    emit('update:modelValue', currentStep.value)
  }
}
</script>

<style scoped>
form {
  margin-top: 1rem;
}
</style>
