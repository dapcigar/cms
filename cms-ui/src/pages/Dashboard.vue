<template>
  <Layout>
    <div class="dashboard-header">
      <h1 class="dashboard-title">Dashboard</h1>

    </div>
    
    <!-- KPI Summary Cards -->
    <div class="stats-cards">
      <Card type="primary" class="stat-card" @click="showUsers = true">
        <div class="stat-icon">
          <span class="material-icons">people</span>
        </div>
        <div class="stat-content">
          <div class="stat-label">Total Users</div>
          <div class="stat-value">{{ stats.users }}</div>
          <div class="stat-trend" :class="{'positive': userTrend > 0, 'negative': userTrend < 0}">
            <span class="material-icons">{{ userTrend > 0 ? 'trending_up' : userTrend < 0 ? 'trending_down' : 'trending_flat' }}</span>
            <span>{{ Math.abs(userTrend) }}% from last period</span>
          </div>
        </div>
      </Card>
      
      <Card type="accent" class="stat-card" @click="showAudits = true">
        <div class="stat-icon">
          <span class="material-icons">assignment</span>
        </div>
        <div class="stat-content">
          <div class="stat-label">Open Audits</div>
          <div class="stat-value">{{ stats.openAudits }}</div>
          <div class="stat-trend" :class="{'positive': auditTrend < 0, 'negative': auditTrend > 0}">
            <span class="material-icons">{{ auditTrend < 0 ? 'trending_up' : auditTrend > 0 ? 'trending_down' : 'trending_flat' }}</span>
            <span>{{ Math.abs(auditTrend) }}% from last period</span>
          </div>
        </div>
      </Card>
      
      <Card type="error" class="stat-card" @click="showIncidents = true">
        <div class="stat-icon">
          <span class="material-icons">report_problem</span>
        </div>
        <div class="stat-content">
          <div class="stat-label">Open Incidents</div>
          <div class="stat-value">{{ stats.openIncidents }}</div>
          <div class="stat-trend" :class="{'positive': incidentTrend < 0, 'negative': incidentTrend > 0}">
            <span class="material-icons">{{ incidentTrend < 0 ? 'trending_up' : incidentTrend > 0 ? 'trending_down' : 'trending_flat' }}</span>
            <span>{{ Math.abs(incidentTrend) }}% from last period</span>
          </div>
        </div>
      </Card>
      
      <Card type="success" class="stat-card">
        <div class="stat-icon">
          <span class="material-icons">security</span>
        </div>
        <div class="stat-content">
          <div class="stat-label">Safeguarding Cases</div>
          <div class="stat-value">{{ stats.safeguardingCases }}</div>
          <div class="stat-trend" :class="{'positive': safeguardingTrend < 0, 'negative': safeguardingTrend > 0}">
            <span class="material-icons">{{ safeguardingTrend < 0 ? 'trending_up' : safeguardingTrend > 0 ? 'trending_down' : 'trending_flat' }}</span>
            <span>{{ Math.abs(safeguardingTrend) }}% from last period</span>
          </div>
        </div>
      </Card>
    </div>
    
    <!-- Charts Section -->
    <div class="charts-grid">
      <div class="chart-card">
        <h2 class="chart-title">Audit Completion</h2>
        <Bar :data="auditBarData" :options="barOptions" />
      </div>
      
      <div class="chart-card">
        <h2 class="chart-title">Incident Resolution</h2>
        <Pie :data="incidentPieData" :options="pieOptions" />
      </div>
    </div>
    
    <!-- Activity Timeline -->
    <div class="activity-section">
      <h2 class="section-title">Recent Activity</h2>
      <div class="timeline">
        <div v-for="(activity, index) in recentActivities" :key="index" class="timeline-item">
          <div class="timeline-icon" :class="getActivityIconClass(activity.type)">
            <span class="material-icons">{{ getActivityIcon(activity.type) }}</span>
          </div>
          <div class="timeline-content">
            <div class="timeline-time">{{ formatDate(activity.timestamp) }}</div>
            <div class="timeline-title">{{ activity.title }}</div>
            <div class="timeline-description">{{ activity.description }}</div>
          </div>
        </div>
      </div>
    </div>
    <!-- Completion Progress Bars -->
    <div class="progress-section">
      <div class="progress-card">
        <div class="progress-header">
          <h3 class="progress-title">Audit Completion Rate</h3>
          <div class="progress-value">{{ stats.auditCompletion }}%</div>
        </div>
        <div class="progress-bar-container">
          <div class="progress-bar" :style="{ width: stats.auditCompletion + '%' }"></div>
        </div>
      </div>
      
      <div class="progress-card">
        <div class="progress-header">
          <h3 class="progress-title">Incident Resolution Rate</h3>
          <div class="progress-value">{{ stats.incidentResolution }}%</div>
        </div>
        <div class="progress-bar-container">
          <div class="progress-bar accent" :style="{ width: stats.incidentResolution + '%' }"></div>
        </div>
      </div>
      
      <div class="progress-card">
        <div class="progress-header">
          <h3 class="progress-title">Safeguarding Case Resolution</h3>
          <div class="progress-value">{{ stats.safeguardingResolution }}%</div>
        </div>
        <div class="progress-bar-container">
          <div class="progress-bar success" :style="{ width: stats.safeguardingResolution + '%' }"></div>
        </div>
      </div>
    </div>
    
    <!-- Performance Metrics -->
    <div class="metrics-grid">
      <div class="metric-card">
        <h3 class="metric-title">Average Resolution Time</h3>
        <div class="metric-value">{{ stats.avgResolutionTime }} days</div>
        <div class="metric-chart">
          <Line :data="resolutionTimeData" :options="lineOptions" height="100" /></div>
      </div>
      
      <div class="metric-card">
        <h3 class="metric-title">Incidents by Type</h3>
        <div class="metric-chart">
          <Doughnut :data="incidentTypeData" :options="doughnutOptions" height="150" />
        </div>
      </div>
    </div>
    <!-- Modals -->
    <Modal :show="showUsers" @close="showUsers = false">
      <h2 class="modal-title">User Details</h2>
      <div class="modal-content">
        <table class="data-table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Email</th>
              <th>Role</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="user in users" :key="user.id">
              <td>{{ user.name || user.email }}</td>
              <td>{{ user.email }}</td>
              <td><span class="badge" :class="user.role === 'admin' ? 'badge-primary' : 'badge-success'">{{ user.role || 'staff' }}</span></td>
              <td><span class="status-dot active"></span> Active</td>
            </tr>
          </tbody>
        </table>
      </div>
    </Modal>
    
    <Modal :show="showAudits" @close="showAudits = false">
      <h2 class="modal-title">Open Audits</h2>
      <div class="modal-content">
        <table class="data-table">
          <thead>
            <tr>
              <th>Title</th>
              <th>Status</th>
              <th>Due Date</th>
              <th>Assigned To</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="audit in audits" :key="audit.id">
              <td>{{ audit.title }}</td>
              <td><span class="badge badge-accent">{{ audit.status }}</span></td>
              <td>{{ formatDate(audit.scheduled_date) }}</td>
              <td>{{ getAssignedNames(audit.assigned_users) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </Modal>
    
    <Modal :show="showIncidents" @close="showIncidents = false">
      <h2 class="modal-title">Open Incidents</h2>
      <div class="modal-content">
        <table class="data-table">
          <thead>
            <tr>
              <th>Type</th>
              <th>Description</th>
              <th>Status</th>
              <th>Reported</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="incident in incidents" :key="incident.id">
              <td><span class="badge" :class="getIncidentTypeClass(incident.type)">{{ incident.type }}</span></td>
              <td>{{ incident.description }}</td>
              <td><span class="badge badge-error">{{ incident.status }}</span></td>
              <td>{{ formatDate(incident.created_at) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </Modal>
  </Layout>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import Layout from '../components/Layout.vue'
import Card from '../components/Card.vue'
import Modal from '../components/Modal.vue'
import Button from '../components/Button.vue'
import { 
  Chart as ChartJS, 
  ArcElement, 
  BarElement, 
  CategoryScale, 
  LinearScale, 
  PointElement,
  LineElement,
  Title, 
  Tooltip, 
  Legend,
  DoughnutController
} from 'chart.js'
import { Bar, Pie, Line, Doughnut } from 'vue-chartjs'
import { supabase } from '../supabase'
import { format, parseISO, subDays } from 'date-fns'

// Register Chart.js components
ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  ArcElement,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  DoughnutController
)

// Dashboard state
const stats = ref({ 
  users: 0, 
  openAudits: 0, 
  openIncidents: 0, 
  auditCompletion: 0,
  incidentResolution: 0,
  safeguardingCases: 0,
  safeguardingResolution: 0,
  avgResolutionTime: 0
})

// Trend indicators (percentage change from previous period)
const userTrend = ref(5)
const auditTrend = ref(-3)
const incidentTrend = ref(2)
const safeguardingTrend = ref(-1)

// (Removed dateRange filter state as date filter UI is removed)

// Modal visibility state
const showUsers = ref(false)
const showAudits = ref(false)
const showIncidents = ref(false)

// Data collections
const users = ref<any[]>([])
const audits = ref<any[]>([])
const incidents = ref<any[]>([])
const safeguardingCases = ref<any[]>([])

// Recent activity timeline
const recentActivities = ref([
  {
    type: 'incident',
    timestamp: new Date('2025-05-09T14:32:00'),
    title: 'New Incident Reported',
    description: 'A complaint was filed regarding facility maintenance.'
  },
  {
    type: 'audit',
    timestamp: new Date('2025-05-08T10:15:00'),
    title: 'Audit Completed',
    description: 'Monthly safety audit was completed with 92% compliance.'
  },
  {
    type: 'user',
    timestamp: new Date('2025-05-07T09:45:00'),
    title: 'New User Added',
    description: 'Sarah Johnson was added as a staff member.'
  },
  {
    type: 'safeguarding',
    timestamp: new Date('2025-05-06T16:20:00'),
    title: 'Safeguarding Case Resolved',
    description: 'Case #SC-2025-042 was successfully resolved.'
  },
  {
    type: 'incident',
    timestamp: new Date('2025-05-05T11:05:00'),
    title: 'Incident Status Updated',
    description: 'Incident #INC-2025-078 status changed to "In Progress".'
  }
])

// Chart data
const auditBarData = ref({
  labels: ['Completed', 'In Progress', 'Pending'],
  datasets: [
    {
      label: 'Audits',
      backgroundColor: ['#10B981', '#0070F3', '#FF7A59'],
      data: [0, 0, 0],
      borderRadius: 6,
    },
  ],
})

const barOptions = { 
  responsive: true, 
  maintainAspectRatio: false,
  plugins: { 
    legend: { display: false },
    tooltip: {
      backgroundColor: '#1F2937',
      padding: 10,
      cornerRadius: 6
    }
  },
  scales: {
    y: {
      beginAtZero: true,
      grid: {
        display: true,
        color: 'rgba(0, 0, 0, 0.05)'
      }
    },
    x: {
      grid: {
        display: false
      }
    }
  }
}

const incidentPieData = ref({
  labels: ['Resolved', 'In Progress', 'Open'],
  datasets: [
    {
      backgroundColor: ['#10B981', '#0070F3', '#FF7A59'],
      data: [0, 0, 0],
      borderWidth: 0,
    },
  ],
})

const pieOptions = { 
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: 'bottom',
      labels: {
        usePointStyle: true,
        padding: 15
      }
    },
    tooltip: {
      backgroundColor: '#1F2937',
      padding: 10,
      cornerRadius: 6
    }
  },
  cutout: '65%'
}

// Line chart for resolution time trend
const resolutionTimeData = ref({
  labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May'],
  datasets: [{
    label: 'Days to Resolve',
    data: [5.2, 4.8, 6.1, 5.0, 4.3],
    borderColor: '#0070F3',
    backgroundColor: 'rgba(0, 112, 243, 0.1)',
    tension: 0.4,
    fill: true
  }]
})

const lineOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { display: false }
  },
  scales: {
    y: {
      beginAtZero: true,
      grid: {
        color: 'rgba(0, 0, 0, 0.05)'
      }
    },
    x: {
      grid: {
        display: false
      }
    }
  }
}

// Doughnut chart for incident types
const incidentTypeData = ref({
  labels: ['Complaint', 'Incident', 'Compliment'],
  datasets: [{
    data: [42, 28, 30],
    backgroundColor: ['#FF7A59', '#EF4444', '#10B981'],
    borderWidth: 0
  }]
})

const doughnutOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: 'bottom',
      labels: {
        usePointStyle: true,
        padding: 15
      }
    }
  },
  cutout: '75%'
}

// Format date for display
function formatDate(dateString) {
  if (!dateString) return 'N/A';
  try {
    const date = typeof dateString === 'string' ? parseISO(dateString) : dateString;
    return format(date, 'MMM d, yyyy');
  } catch (e) {
    return 'Invalid date';
  }
}

// Get icon class based on activity type
function getActivityIconClass(type) {
  switch (type) {
    case 'incident': return 'bg-error';
    case 'audit': return 'bg-primary';
    case 'user': return 'bg-info';
    case 'safeguarding': return 'bg-success';
    default: return 'bg-accent';
  }
}

// Get icon based on activity type
function getActivityIcon(type) {
  switch (type) {
    case 'incident': return 'report_problem';
    case 'audit': return 'assignment';
    case 'user': return 'person';
    case 'safeguarding': return 'security';
    default: return 'event_note';
  }
}

// Get CSS class for incident type badge
function getIncidentTypeClass(type) {
  switch (type?.toLowerCase()) {
    case 'complaint': return 'badge-accent';
    case 'incident': return 'badge-error';
    case 'compliment': return 'badge-success';
    default: return 'badge-primary';
  }
}

// Get assigned user names from user IDs
function getAssignedNames(userIds) {
  if (!userIds || !Array.isArray(userIds) || userIds.length === 0) return 'Unassigned';
  
  // In a real app, you would look up the names from the users array
  return userIds.length === 1 ? '1 user' : `${userIds.length} users`;
}

async function fetchStats() {
  try {
    // Use profiles table instead of users
    let userQuery = supabase.from('profiles').select('*', { count: 'exact', head: true })
    let auditQuery = supabase.from('audits').select('*', { count: 'exact', head: true })
    let incidentQuery = supabase.from('incidents').select('*', { count: 'exact', head: true })
    let safeguardingQuery = supabase.from('safeguarding').select('*', { count: 'exact', head: true })
    let allAuditsQuery = supabase.from('audits').select('status')
    let allIncidentsQuery = supabase.from('incidents').select('status')
    let allSafeguardingQuery = supabase.from('safeguarding').select('status')
    let usersListQuery = supabase.from('profiles').select('id, email, role')
    let auditsListQuery = supabase.from('audits').select('id, title, status, scheduled_date, assigned_users')
    let incidentsListQuery = supabase.from('incidents').select('id, type, description, status, created_at')



    // Get counts
    // Enhanced error logging for Supabase queries
    const { count: userCount, error: userErr, ...userResp } = await userQuery
    if (userErr) console.error('[Supabase] userQuery error:', userErr, userResp)
    const { count: openAudits, error: auditErr, ...auditResp } = await auditQuery.eq('status', 'open')
    if (auditErr) console.error('[Supabase] auditQuery error:', auditErr, auditResp)
    const { count: openIncidents, error: incidentErr, ...incidentResp } = await incidentQuery.eq('status', 'open')
    if (incidentErr) console.error('[Supabase] incidentQuery error:', incidentErr, incidentResp)
    const { count: safeguardingCount, error: safeguardingErr, ...safeguardingResp } = await safeguardingQuery
    if (safeguardingErr) console.error('[Supabase] safeguardingQuery error:', safeguardingErr, safeguardingResp)
    
    // Get completion rates
    const { data: allAudits, error: allAuditsErr, ...allAuditsResp } = await allAuditsQuery
    if (allAuditsErr) console.error('[Supabase] allAuditsQuery error:', allAuditsErr, allAuditsResp)
    const { data: allIncidents, error: allIncidentsErr, ...allIncidentsResp } = await allIncidentsQuery
    if (allIncidentsErr) console.error('[Supabase] allIncidentsQuery error:', allIncidentsErr, allIncidentsResp)
    const { data: allSafeguarding, error: allSafeguardingErr, ...allSafeguardingResp } = await allSafeguardingQuery
    if (allSafeguardingErr) console.error('[Supabase] allSafeguardingQuery error:', allSafeguardingErr, allSafeguardingResp)
    
    // Calculate completion percentages
    const completedAudits = allAudits?.filter((a: any) => a.status === 'closed').length || 0
    const totalAudits = allAudits?.length || 1 // Avoid division by zero
    const auditCompletion = Math.round((completedAudits / totalAudits) * 100)
    
    const resolvedIncidents = allIncidents?.filter((i: any) => i.status === 'closed').length || 0
    const totalIncidents = allIncidents?.length || 1
    const incidentResolution = Math.round((resolvedIncidents / totalIncidents) * 100)
    
    const resolvedSafeguarding = allSafeguarding?.filter((s: any) => s.status === 'resolved').length || 0
    const totalSafeguarding = allSafeguarding?.length || 1
    const safeguardingResolution = Math.round((resolvedSafeguarding / totalSafeguarding) * 100)
    
    // Update stats
    stats.value = {
      users: userCount || 0,
      openAudits: openAudits || 0,
      openIncidents: openIncidents || 0,
      safeguardingCases: safeguardingCount || 0,
      auditCompletion,
      incidentResolution,
      safeguardingResolution,
      avgResolutionTime: 4.3 // Sample data
    }
    
    // Get detailed data for modals
    const { data: usersData, error: usersListErr, ...usersListResp } = await usersListQuery
    if (usersListErr) console.error('[Supabase] usersListQuery error:', usersListErr, usersListResp)
    const { data: auditsData, error: auditsListErr, ...auditsListResp } = await auditsListQuery.eq('status', 'open')
    if (auditsListErr) console.error('[Supabase] auditsListQuery error:', auditsListErr, auditsListResp)
    const { data: incidentsData, error: incidentsListErr, ...incidentsListResp } = await incidentsListQuery.eq('status', 'open')
    if (incidentsListErr) console.error('[Supabase] incidentsListQuery error:', incidentsListErr, incidentsListResp)
    
    users.value = usersData || []
    audits.value = auditsData || []
    incidents.value = incidentsData || []

    // Update bar chart data
    const inProgressAudits = allAudits?.filter((a: any) => a.status === 'in_progress').length || 0
    const pendingAudits = allAudits?.filter((a: any) => a.status === 'pending').length || 0
    auditBarData.value.datasets[0].data = [completedAudits, inProgressAudits, pendingAudits]

    // Update pie chart data
    const inProgressIncidents = allIncidents?.filter((i: any) => i.status === 'in_progress').length || 0
    incidentPieData.value.datasets[0].data = [resolvedIncidents, inProgressIncidents, openIncidents]
    
  } catch (e) {
    console.error('Error fetching dashboard stats:', e);
    console.error('[DEBUG] typeof error:', typeof e);
    if (e && typeof e === 'object') {
      console.error('[DEBUG] error keys:', Object.keys(e));
      try {
        console.error('[DEBUG] error JSON:', JSON.stringify(e));
      } catch (jsonErr) {
        console.error('[DEBUG] error could not be stringified:', jsonErr);
      }
      if (e.stack) {
        console.error('[DEBUG] error stack:', e.stack);
      }
    }
  }
}

onMounted(fetchStats)
</script>

<style scoped>
/* Dashboard Layout */
.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  flex-wrap: wrap;
  gap: 1rem;
}

.dashboard-title {
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--color-text);
  margin: 0;
}

.date-filter {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.filter-label {
  font-weight: 500;
  color: var(--color-text);
}

.date-input {
  padding: 0.5rem;
  border: 1px solid #E5E7EB;
  border-radius: 0.375rem;
  min-height: 42px;
}

.filter-button {
  background-color: var(--color-primary);
  color: white;
  border: none;
  border-radius: 0.375rem;
  padding: 0.5rem 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  min-height: 42px;
}

/* KPI Cards */
.stats-cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.stat-card {
  background-color: white;
  border-radius: 0.5rem;
  padding: 1.25rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  gap: 1rem;
  transition: all 0.2s ease;
  cursor: pointer;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.stat-card.primary {
  border-left: 4px solid var(--color-primary);
}

.stat-card.accent {
  border-left: 4px solid var(--color-accent);
}

.stat-card.error {
  border-left: 4px solid var(--color-error);
}

.stat-card.success {
  border-left: 4px solid var(--color-success);
}

.stat-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  border-radius: 0.5rem;
  background-color: rgba(0, 112, 243, 0.1);
  color: var(--color-primary);
}

.primary .stat-icon {
  background-color: rgba(0, 112, 243, 0.1);
  color: var(--color-primary);
}

.accent .stat-icon {
  background-color: rgba(255, 122, 89, 0.1);
  color: var(--color-accent);
}

.error .stat-icon {
  background-color: rgba(239, 68, 68, 0.1);
  color: var(--color-error);
}

.success .stat-icon {
  background-color: rgba(16, 185, 129, 0.1);
  color: var(--color-success);
}

.stat-content {
  flex: 1;
}

.stat-label {
  font-size: 0.875rem;
  color: var(--color-text);
  opacity: 0.8;
}

.stat-value {
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--color-text);
  margin: 0.25rem 0;
}

.stat-trend {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.75rem;
  color: var(--color-text);
  opacity: 0.7;
}

.stat-trend.positive {
  color: var(--color-success);
}

.stat-trend.negative {
  color: var(--color-error);
}

/* Charts */
.charts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(450px, 1fr));
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

@media (max-width: 768px) {
  .charts-grid {
    grid-template-columns: 1fr;
  }
}

.chart-card {
  background-color: white;
  border-radius: 0.5rem;
  padding: 1.25rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  height: 300px;
}

.chart-title {
  font-size: 1.125rem;
  font-weight: 600;
  color: var(--color-text);
  margin-bottom: 1rem;
}

/* Progress Bars */
.progress-section {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.progress-card {
  background-color: white;
  border-radius: 0.5rem;
  padding: 1.25rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.progress-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
}

.progress-title {
  font-size: 1rem;
  font-weight: 500;
  color: var(--color-text);
}

.progress-value {
  font-size: 1rem;
  font-weight: 600;
  color: var(--color-primary);
}

.progress-bar-container {
  height: 8px;
  background-color: rgba(0, 0, 0, 0.05);
  border-radius: 9999px;
  overflow: hidden;
}

.progress-bar {
  height: 100%;
  background-color: var(--color-primary);
  border-radius: 9999px;
  transition: width 0.5s ease;
}

.progress-bar.accent {
  background-color: var(--color-accent);
}

.progress-bar.success {
  background-color: var(--color-success);
}

/* Metrics Grid */
.metrics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(450px, 1fr));
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

@media (max-width: 768px) {
  .metrics-grid {
    grid-template-columns: 1fr;
  }
}

.metric-card {
  background-color: white;
  border-radius: 0.5rem;
  padding: 1.25rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.metric-title {
  font-size: 1.125rem;
  font-weight: 600;
  color: var(--color-text);
  margin-bottom: 0.5rem;
}

.metric-value {
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--color-primary);
  margin-bottom: 1rem;
}

.metric-chart {
  height: 150px;
}

/* Activity Timeline */
.activity-section {
  margin-bottom: 1.5rem;
}

.section-title {
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--color-text);
  margin-bottom: 1rem;
}

.timeline {
  position: relative;
  padding-left: 2rem;
}

.timeline::before {
  content: '';
  position: absolute;
  top: 0;
  bottom: 0;
  left: 8px;
  width: 2px;
  background-color: rgba(0, 0, 0, 0.1);
}

.timeline-item {
  position: relative;
  padding-bottom: 1.5rem;
}

.timeline-icon {
  position: absolute;
  left: -2rem;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 12px;
  z-index: 1;
}

.timeline-icon .material-icons {
  font-size: 12px;
}

.timeline-icon.bg-primary {
  background-color: var(--color-primary);
}

.timeline-icon.bg-accent {
  background-color: var(--color-accent);
}

.timeline-icon.bg-success {
  background-color: var(--color-success);
}

.timeline-icon.bg-error {
  background-color: var(--color-error);
}

.timeline-icon.bg-info {
  background-color: var(--color-info);
}

.timeline-content {
  background-color: white;
  border-radius: 0.5rem;
  padding: 1rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.timeline-time {
  font-size: 0.75rem;
  color: var(--color-text);
  opacity: 0.7;
  margin-bottom: 0.25rem;
}

.timeline-title {
  font-size: 0.9375rem;
  font-weight: 600;
  color: var(--color-text);
  margin-bottom: 0.25rem;
}

.timeline-description {
  font-size: 0.875rem;
  color: var(--color-text);
  opacity: 0.8;
}

/* Modal Styles */
.modal-title {
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--color-text);
  margin-bottom: 1rem;
}

.modal-content {
  max-height: 60vh;
  overflow-y: auto;
}

.data-table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
}

.data-table th {
  text-align: left;
  padding: 0.75rem;
  background-color: var(--color-background);
  font-weight: 500;
  color: var(--color-text);
  border-bottom: 1px solid #E5E7EB;
}

.data-table td {
  padding: 0.75rem;
  border-bottom: 1px solid #E5E7EB;
}

.data-table tr:hover td {
  background-color: rgba(0, 0, 0, 0.02);
}

.badge {
  display: inline-flex;
  align-items: center;
  padding: 0.25rem 0.5rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 500;
  text-transform: capitalize;
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

.badge-error {
  background-color: rgba(239, 68, 68, 0.1);
  color: var(--color-error);
}

.status-dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  margin-right: 0.5rem;
}

.status-dot.active {
  background-color: var(--color-success);
}

.status-dot.inactive {
  background-color: var(--color-error);
}
</style>
