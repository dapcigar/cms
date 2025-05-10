<template>
  <Teleport to="body">
    <transition name="fade">
      <div v-if="show" class="modal-backdrop" @click.self="$emit('close')">
        <div class="modal-container">
          <button @click="$emit('close')" class="modal-close">&times;</button>
          <slot />
        </div>
      </div>
    </transition>
  </Teleport>
</template>

<script setup lang="ts">
defineProps({
  show: Boolean,
});

defineEmits(['close']);
</script>

<style scoped>
.modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 50;
}

.modal-container {
  background-color: white;
  border-radius: 0.5rem;
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.2);
  width: 100%;
  max-width: 500px;
  padding: 1.5rem;
  position: relative;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-close {
  position: absolute;
  top: 0.75rem;
  right: 0.75rem;
  background-color: transparent;
  border: none;
  font-size: 1.5rem;
  line-height: 1;
  cursor: pointer;
  color: rgba(0, 0, 0, 0.4);
  transition: color 0.2s ease;
}

.modal-close:hover {
  color: var(--color-text);
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
