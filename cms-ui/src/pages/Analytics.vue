<template>
  <Layout>
    <div class="dashboard-header">
      <h1 class="dashboard-title">Analytics Dashboard</h1>
      <div class="dashboard-actions">
        <Button color="primary">Export</Button>
        <Button color="accent">Filter</Button>
      </div>
    </div>
    
    <!-- Loading and Error States -->
    <div v-if="loading" class="loading-container">
      <div class="loading-spinner"></div>
      <p class="loading-text">Loading analytics data...</p>
    </div>
    
    <div v-if="error" class="error-message">
      <span class="error-icon">error</span>
      <p>{{ error }}</p>
      <Button @click="fetchAnalyticsData" color="primary" size="small">Retry</Button>
    </div>

    <!-- KPI Cards -->
    <div class="stats-grid">
      <div class="stat-card stat-primary">
        <span class="stat-icon">assessment</span>
        <div class="stat-value">{{ kpi.incidents }}</div>
        <div class="stat-label">Total Incidents</div>
      </div>
      <div class="stat-card stat-accent">
        <span class="stat-icon">report</span>
        <div class="stat-value">{{ kpi.complaints }}</div>
        <div class="stat-label">Total Complaints</div>
      </div>
      <div class="stat-card stat-success">
        <span class="stat-icon">check_circle</span>
        <div class="stat-value">{{ kpi.completedActions }}</div>
        <div class="stat-label">Completed Actions</div>
      </div>
      <div class="stat-card stat-info">
        <span class="stat-icon">insights</span>
        <div class="stat-value">{{ kpi.openCases }}</div>
        <div class="stat-label">Open Safeguarding</div>
      </div>
    </div>

    <!-- Charts Row -->
    <div class="charts-grid">
  <div class="chart-card">
    <h2 class="chart-title">Incidents Over Time</h2>
    <div class="chart-container">
      <Bar :data="incidentsChartData" :options="incidentsChartOptions" />
    </div>
  </div>
  <div class="chart-card">
    <h2 class="chart-title">Complaints by Status</h2>
    <div class="chart-container">
      <Pie :data="complaintsChartData" :options="complaintsChartOptions" />
    </div>
  </div>
</div>

    <!-- Table Row -->
    <div class="data-card">
      <h2 class="data-title">Recent Activity</h2>
      <div class="table-container">
        <table class="data-table">
          <thead>
            <tr>
              <th>Date</th>
              <th>Type</th>
              <th>Description</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in recentActivity" :key="item.id">
              <td>{{ item.date }}</td>
              <td>
                <span class="status-badge" :class="getTypeClass(item.type)">{{ item.type }}</span>
              </td>
              <td>{{ item.description }}</td>
              <td>
                <span class="status-badge" :class="getStatusClass(item.status)">{{ item.status }}</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </Layout>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import Layout from '../components/Layout.vue'
import Button from '../components/Button.vue'
import { supabase } from '../lib/supabaseClient'
import { Bar, Pie } from 'vue-chartjs'
import {
  Chart,
  Title,
  Tooltip,
  Legend,
  BarElement,
  CategoryScale,
  LinearScale,
  ArcElement
} from 'chart.js'

// Register Chart.js components
Chart.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale, ArcElement)

let kpi = ref({ incidents: 0, complaints: 0, completedActions: 0, openCases: 0 })
let recentActivity = ref<any[]>([])
let loading = ref(false)
let error = ref('')

// Chart Data and Options
const incidentsChartData = ref({
  labels: ['Jan', 'Feb', 'Mar', 'Apr'],
  datasets: [
    {
      label: 'Incidents',
      backgroundColor: '#0070F3',
      borderColor: '#0070F3',
      data: [10, 20, 15, 30], // Replace with real data if available
      borderRadius: 8,
      barPercentage: 0.7
    }
  ]
})
const incidentsChartOptions = ref({
  responsive: true,
  plugins: {
    legend: { display: false },
    title: { display: false }
  },
  scales: {
    x: { ticks: { color: '#1F2937' }, grid: { color: '#F9FAFB' } },
    y: { ticks: { color: '#1F2937' }, grid: { color: '#F9FAFB' }, beginAtZero: true }
  }
})

const complaintsChartData = ref({
  labels: ['Open', 'Closed'],
  datasets: [
    {
      label: 'Complaints',
      backgroundColor: ['#FF7A59', '#10B981'],
      borderColor: ['#FF7A59', '#10B981'],
      data: [1, 0] // Replace with real data if available
    }
  ]
})
const complaintsChartOptions = ref({
  responsive: true,
  plugins: {
    legend: {
      labels: { color: '#1F2937', font: { family: 'Inter, Open Sans, sans-serif', size: 14 } }
    },
    title: { display: false }
  }
})

// Helper functions for status badges
function getTypeClass(type: string) {
  switch(type.toLowerCase()) {
    case 'incident': return 'badge-primary';
    case 'complaint': return 'badge-accent';
    case 'action': return 'badge-success';
    case 'safeguarding': return 'badge-info';
    default: return 'badge-primary';
  }
}

function getStatusClass(status: string) {
  switch(status.toLowerCase()) {
    case 'open': return 'badge-accent';
    case 'closed': return 'badge-success';
    case 'completed': return 'badge-success';
    case 'in progress': return 'badge-primary';
    default: return 'badge-primary';
  }
}

// Fetch data from Supabase
async function fetchAnalyticsData() {
  loading.value = true
  error.value = ''
  
  try {
    // Fetch KPI data
    const [incidentsResponse, complaintsResponse, safeguardingResponse, actionPlansResponse] = await Promise.all([
      supabase.from('incidents').select('count').eq('status', 'open'),
      supabase.from('complaints').select('count'),
      supabase.from('safeguarding_cases').select('count').eq('status', 'open'),
      supabase.from('action_plans').select('count').eq('status', 'completed')
    ])
    
    // Check for errors in each response
    if (incidentsResponse.error) {
      console.error('Error fetching incidents count:', incidentsResponse.error)
      throw new Error(`Error fetching incidents: ${incidentsResponse.error.message}`)
    }
    
    if (complaintsResponse.error) {
      console.error('Error fetching complaints count:', complaintsResponse.error)
      throw new Error(`Error fetching complaints: ${complaintsResponse.error.message}`)
    }
    
    if (safeguardingResponse.error) {
      console.error('Error fetching safeguarding count:', safeguardingResponse.error)
      throw new Error(`Error fetching safeguarding cases: ${safeguardingResponse.error.message}`)
    }
    
    if (actionPlansResponse.error) {
      console.error('Error fetching action plans count:', actionPlansResponse.error)
      throw new Error(`Error fetching action plans: ${actionPlansResponse.error.message}`)
    }
    
    // Update KPI data
    kpi.value = {
      incidents: incidentsResponse.count || 0,
      complaints: complaintsResponse.count || 0,
      openCases: safeguardingResponse.count || 0,
      completedActions: actionPlansResponse.count || 0
    }
    
    // Fetch recent activity
    const { data: recentData, error: recentError } = await supabase
      .from('activity_log')
      .select('id, created_at, type, description, status')
      .order('created_at', { ascending: false })
      .limit(10)
    
    if (recentError) {
      console.error('Error fetching recent activity:', recentError)
      throw new Error(`Error fetching recent activity: ${recentError.message}`)
    }
    
    // Format the data for display
    recentActivity.value = recentData?.map(item => ({
      id: item.id,
      date: new Date(item.created_at).toISOString().split('T')[0],
      type: item.type,
      description: item.description,
      status: item.status
    })) || []
    
    // Initialize charts after data is loaded
    initializeCharts()
  } catch (e) {
    console.error('Error in fetchAnalyticsData:', e)
    if (e instanceof Error) {
      error.value = e.message
      console.error('Error details:', { 
        message: e.message, 
        stack: e.stack,
        name: e.name
      })
    } else {
      error.value = 'An unexpected error occurred'
      console.error('Unexpected error object:', e)
    }
  } finally {
    loading.value = false
  }
}

// Initialize Chart.js charts
function initializeCharts() {
  try {
    if (!window.Chart) {
      console.error('Chart.js is not loaded')
      return
    }
    
    // Get incidents data for chart
    supabase
      .from('incidents')
      .select('created_at')
      .order('created_at', { ascending: true })
      .then(({ data, error: incidentsError }) => {
        if (incidentsError) {
          console.error('Error fetching incidents chart data:', incidentsError)
          return
        }
        
        // Process data for chart
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
        const counts = Array(12).fill(0)
        
        data?.forEach(incident => {
          const date = new Date(incident.created_at)
          const monthIndex = date.getMonth()
          counts[monthIndex]++
        })
        
        // Create incidents chart
        const incidentsCanvas = document.getElementById('incidentsChart')
        if (incidentsCanvas) {
          new window.Chart(incidentsCanvas, {
            type: 'line',
            data: {
              labels: months,
              datasets: [{ 
                label: 'Incidents', 
                data: counts, 
                borderColor: '#0070F3', 
                backgroundColor: 'rgba(0,112,243,0.1)' 
              }]
            },
            options: { 
              responsive: true, 
              plugins: { legend: { display: false } },
              scales: {
                y: {
                  beginAtZero: true,
                  ticks: { precision: 0 }
                }
              }
            }
          })
        }
      })
    
    // Get complaints data for chart
    supabase
      .from('complaints')
      .select('status')
      .then(({ data, error: complaintsError }) => {
        if (complaintsError) {
          console.error('Error fetching complaints chart data:', complaintsError)
          return
        }
        
        // Count complaints by status
        const statusCounts = {
          'open': 0,
          'closed': 0,
          'resolved': 0
        }
        
        data?.forEach(complaint => {
          const status = complaint.status?.toLowerCase() || 'open'
          if (status in statusCounts) {
            statusCounts[status]++
          }
        })
        
        // Create complaints chart
        const complaintsCanvas = document.getElementById('complaintsChart')
        if (complaintsCanvas) {
          new window.Chart(complaintsCanvas, {
            type: 'doughnut',
            data: {
              labels: ['Open', 'Closed', 'Resolved'],
              datasets: [{ 
                data: [statusCounts.open, statusCounts.closed, statusCounts.resolved], 
                backgroundColor: ['#3B82F6', '#10B981', '#EF4444'] 
              }]
            },
            options: { 
              responsive: true, 
              plugins: { legend: { position: 'bottom' } } 
            }
          })
        }
      })
  } catch (chartError) {
    console.error('Error initializing charts:', chartError)
    if (chartError instanceof Error) {
      console.error('Chart error details:', { 
        message: chartError.message, 
        stack: chartError.stack,
        name: chartError.name
      })
    }
  }
}

onMounted(() => {
  fetchAnalyticsData()
})
</script>

<style scoped>
/* Dashboard Header */
.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.dashboard-title {
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--color-text);
  margin: 0;
}

.dashboard-actions {
  display: flex;
  gap: 0.5rem;
}

/* Stats Cards */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(1, 1fr);
  gap: 1rem;
  margin-bottom: 1.5rem;
}

@media (min-width: 640px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 768px) {
  .stats-grid {
    grid-template-columns: repeat(4, 1fr);
  }
}

.stat-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 1.5rem;
  border-radius: 0.75rem;
  color: white;
  min-height: 140px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  transition: transform 0.2s ease;
}

.stat-card:hover {
  transform: translateY(-4px);
}

.stat-primary {
  background-color: var(--color-primary);
}

.stat-accent {
  background-color: var(--color-accent);
}

.stat-success {
  background-color: var(--color-success);
}

.stat-info {
  background-color: var(--color-info);
}

.stat-icon {
  font-family: 'Material Icons';
  font-size: 2.5rem;
  margin-bottom: 0.75rem;
}

.stat-value {
  font-size: 1.75rem;
  font-weight: 700;
  margin-bottom: 0.25rem;
}

.stat-label {
  font-size: 1rem;
  opacity: 0.9;
}

/* Charts */
.charts-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

@media (min-width: 768px) {
  .charts-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

.chart-card {
  background-color: white;
  border-radius: 0.75rem;
  padding: 1.5rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.chart-title {
  font-size: 1.125rem;
  font-weight: 600;
  color: var(--color-text);
  margin-bottom: 1rem;
}

.chart-container {
  height: 250px;
  position: relative;
}

/* Data Table */
.data-card {
  background-color: white;
  border-radius: 0.75rem;
  padding: 1.5rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  margin-bottom: 1.5rem;
}

.data-title {
  font-size: 1.125rem;
  font-weight: 600;
  color: var(--color-text);
  margin-bottom: 1rem;
}

.table-container {
  overflow-x: auto;
}

.data-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.875rem;
}

.data-table th {
  text-align: left;
  padding: 0.75rem 1rem;
  background-color: var(--color-background);
  font-weight: 500;
  color: var(--color-text);
  border-bottom: 1px solid #E5E7EB;
}

.data-table td {
  padding: 0.75rem 1rem;
  border-bottom: 1px solid #E5E7EB;
  color: var(--color-text);
}

.data-table tr:hover td {
  background-color: rgba(0, 0, 0, 0.02);
}

/* Status Badges */
.status-badge {
  display: inline-flex;
  align-items: center;
  padding: 0.25rem 0.5rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 500;
}

.badge-primary {
  background-color: rgba(0, 112, 243, 0.1);
  color: var(--color-primary);
}

.badge-accent {
  background-color: rgba(255, 122, 89, 0.1);
  color: var(--color-accent);
}

.badge-success {
  background-color: rgba(16, 185, 129, 0.1);
  color: var(--color-success);
}

.badge-info {
  background-color: rgba(59, 130, 246, 0.1);
  color: var(--color-info);
}

/* Loading Indicator */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 2rem;
  background-color: white;
  border-radius: 0.75rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  margin-bottom: 1.5rem;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 3px solid rgba(0, 112, 243, 0.1);
  border-radius: 50%;
  border-top-color: var(--color-primary);
  animation: spin 1s ease-in-out infinite;
  margin-bottom: 1rem;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.loading-text {
  color: var(--color-text);
  font-size: 0.875rem;
}

/* Error Message */
.error-message {
  display: flex;
  align-items: center;
  padding: 1rem 1.5rem;
  background-color: rgba(239, 68, 68, 0.1);
  border-left: 4px solid var(--color-error);
  border-radius: 0.5rem;
  margin-bottom: 1.5rem;
}

.error-icon {
  font-family: 'Material Icons';
  color: var(--color-error);
  font-size: 1.5rem;
  margin-right: 0.75rem;
}

.error-message p {
  flex: 1;
  color: var(--color-text);
  margin: 0 1rem 0 0;
}
</style>
