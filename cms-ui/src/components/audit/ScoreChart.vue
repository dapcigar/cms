<template>
  <div class="score-chart">
    <canvas ref="chartCanvas"></canvas>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
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
    type: 'line',
    data: {
      labels: props.data.map((item: any) => item.score_range),
      datasets: [{
        label: 'Number of Audits',
        data: props.data.map((item: any) => item.count),
        backgroundColor: 'rgba(0, 112, 243, 0.2)',
        borderColor: '#0070F3',
        borderWidth: 2,
        tension: 0.1,
        fill: true
      }]
    },
    options: {
      responsive: true,
      scales: {
        y: {
          beginAtZero: true
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
.score-chart {
  @apply w-full h-64;
}
</style>
