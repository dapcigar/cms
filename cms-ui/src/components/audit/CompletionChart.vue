<template>
  <div class="completion-chart">
    <canvas ref="chartCanvas"></canvas>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch, onBeforeUnmount } from 'vue'
import Chart from 'chart.js/auto'

const props = defineProps({
  data: {
    type: Array,
    required: true
  }
})

const chartCanvas = ref<HTMLCanvasElement | null>(null)
let chartInstance: Chart | null = null

function renderChart() {
  if (!chartCanvas.value) return
  
  // Destroy previous chart instance if exists
  if (chartInstance) {
    chartInstance.destroy()
  }
  
  const ctx = chartCanvas.value.getContext('2d')
  if (!ctx) return
  
  chartInstance = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: props.data.map((item: any) => item.template_title),
      datasets: [{
        label: 'Completion Rate (%)',
        data: props.data.map((item: any) => item.completion_rate),
        backgroundColor: '#0070F3',
        borderColor: '#005BCC',
        borderWidth: 1
      }]
    },
    options: {
      responsive: true,
      scales: {
        y: {
          beginAtZero: true,
          max: 100,
          ticks: {
            callback: (value) => `${value}%`
          }
        }
      }
    }
  })
}

// Watch for data changes
watch(() => props.data, () => {
  renderChart()
}, { deep: true })

// Initialize chart
onMounted(() => {
  renderChart()
})

// Clean up
onBeforeUnmount(() => {
  if (chartInstance) {
    chartInstance.destroy()
  }
})
</script>

<style scoped>
.completion-chart {
  @apply w-full h-64;
}
</style>
