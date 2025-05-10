<template>
  <Layout>
    <div class="flex justify-between items-center mb-6">
      <h1 class="font-heading text-2xl">Analytics Dashboard</h1>
      <div class="flex gap-2">
        <Button color="primary">Export</Button>
        <Button color="accent">Filter</Button>
      </div>
    </div>

    <!-- KPI Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-6 mb-8">
      <div class="card flex flex-col items-center bg-primary text-white">
        <span class="material-icons text-4xl mb-2">assessment</span>
        <div class="text-2xl font-bold">{{ kpi.incidents }}</div>
        <div class="text-base">Total Incidents</div>
      </div>
      <div class="card flex flex-col items-center bg-accent text-white">
        <span class="material-icons text-4xl mb-2">report</span>
        <div class="text-2xl font-bold">{{ kpi.complaints }}</div>
        <div class="text-base">Total Complaints</div>
      </div>
      <div class="card flex flex-col items-center bg-success text-white">
        <span class="material-icons text-4xl mb-2">check_circle</span>
        <div class="text-2xl font-bold">{{ kpi.completedActions }}</div>
        <div class="text-base">Completed Actions</div>
      </div>
      <div class="card flex flex-col items-center bg-info text-white">
        <span class="material-icons text-4xl mb-2">insights</span>
        <div class="text-2xl font-bold">{{ kpi.openCases }}</div>
        <div class="text-base">Open Safeguarding</div>
      </div>
    </div>

    <!-- Charts Row -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-8 mb-8">
      <div class="card">
        <h2 class="font-heading text-lg mb-2">Incidents Over Time</h2>
        <canvas id="incidentsChart"></canvas>
      </div>
      <div class="card">
        <h2 class="font-heading text-lg mb-2">Complaints by Status</h2>
        <canvas id="complaintsChart"></canvas>
      </div>
    </div>

    <!-- Table Row -->
    <div class="card mb-8 overflow-x-auto">
      <h2 class="font-heading text-lg mb-2">Recent Activity</h2>
      <table class="min-w-full text-sm">
        <thead>
          <tr>
            <th class="text-left p-2">Date</th>
            <th class="text-left p-2">Type</th>
            <th class="text-left p-2">Description</th>
            <th class="text-left p-2">Status</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in recentActivity" :key="item.id">
            <td class="p-2">{{ item.date }}</td>
            <td class="p-2">{{ item.type }}</td>
            <td class="p-2">{{ item.description }}</td>
            <td class="p-2">{{ item.status }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </Layout>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import Layout from '../components/Layout.vue'
import Button from '../components/Button.vue'
let kpi = ref({ incidents: 0, complaints: 0, completedActions: 0, openCases: 0 })
let recentActivity = ref<any[]>([])

// Placeholder: Replace with real data fetch
onMounted(() => {
  kpi.value = {
    incidents: 42,
    complaints: 15,
    completedActions: 28,
    openCases: 8,
  }
  recentActivity.value = [
    { id: 1, date: '2025-05-10', type: 'Incident', description: 'Medication error', status: 'Open' },
    { id: 2, date: '2025-05-09', type: 'Complaint', description: 'Late response', status: 'Closed' },
    { id: 3, date: '2025-05-08', type: 'Action', description: 'Follow-up call', status: 'Completed' },
    { id: 4, date: '2025-05-07', type: 'Safeguarding', description: 'Allegation review', status: 'Open' },
  ]
  // Charts (using Chart.js or similar in real app)
  // This is placeholder only
  if (window.Chart) {
    new window.Chart(document.getElementById('incidentsChart'), {
      type: 'line',
      data: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May'],
        datasets: [{ label: 'Incidents', data: [5, 9, 7, 12, 8], borderColor: '#0070F3', backgroundColor: 'rgba(0,112,243,0.1)' }]
      },
      options: { responsive: true, plugins: { legend: { display: false } } }
    })
    new window.Chart(document.getElementById('complaintsChart'), {
      type: 'doughnut',
      data: {
        labels: ['Open', 'Closed', 'Resolved'],
        datasets: [{ data: [7, 5, 3], backgroundColor: ['#3B82F6', '#10B981', '#EF4444'] }]
      },
      options: { responsive: true, plugins: { legend: { position: 'bottom' } } }
    })
  }
})
</script>

<style scoped>
.card {
  min-height: 120px;
  border-radius: 1rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  padding: 2em;
  background: #fff;
  display: flex;
  flex-direction: column;
  justify-content: center;
}
</style>
