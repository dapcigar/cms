<template>
  <Layout>
    <h1 class="font-heading text-2xl mb-6">Dashboard</h1>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-8 mb-8">
      <div class="bg-white rounded-lg shadow p-6">
        <h2 class="font-heading text-xl mb-4">Audit Completion (Bar Chart)</h2>
        <Bar :data="auditBarData" :options="barOptions" />
      </div>
      <div class="bg-white rounded-lg shadow p-6">
        <h2 class="font-heading text-xl mb-4">Incident Resolution (Pie Chart)</h2>
        <Pie :data="incidentPieData" :options="pieOptions" />
      </div>
    </div>
    <div class="flex items-center gap-4 mb-6">
      <label class="font-semibold">From:</label>
      <input type="date" v-model="dateRange.start" class="p-2 border rounded" />
      <label class="font-semibold">To:</label>
      <input type="date" v-model="dateRange.end" class="p-2 border rounded" />
      <Button color="primary" @click="fetchStats">Filter</Button>
    </div>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
      <Card class="bg-primary text-white cursor-pointer" @click="showUsers = true">
        <div class="font-bold text-lg">Total Users</div>
        <div class="text-3xl mt-2">{{ stats.users }}</div>
      </Card>
      <Card class="bg-accent text-white cursor-pointer" @click="showAudits = true">
        <div class="font-bold text-lg">Open Audits</div>
        <div class="text-3xl mt-2">{{ stats.openAudits }}</div>
      </Card>
      <Card class="bg-secondary text-white cursor-pointer" @click="showIncidents = true">
        <div class="font-bold text-lg">Open Incidents</div>
        <div class="text-3xl mt-2">{{ stats.openIncidents }}</div>
      </Card>
    </div>
    <div class="bg-white rounded-lg shadow p-6">
      <h2 class="font-heading text-xl mb-4">Audit Completion Rate</h2>
      <div class="w-full bg-gray-200 rounded-full h-6 mb-4">
        <div class="bg-primary h-6 rounded-full" :style="{ width: stats.auditCompletion + '%' }"></div>
      </div>
      <div class="text-right text-sm text-gray-600">{{ stats.auditCompletion }}% complete</div>
    </div>
    <Modal :show="showUsers" @close="showUsers = false">
      <h2 class="font-heading text-xl mb-4">Users</h2>
      <ul>
        <li v-for="user in users" :key="user.id">{{ user.name }} ({{ user.email }})</li>
      </ul>
    </Modal>
    <Modal :show="showAudits" @close="showAudits = false">
      <h2 class="font-heading text-xl mb-4">Open Audits</h2>
      <ul>
        <li v-for="audit in audits" :key="audit.id">{{ audit.title }} (Status: {{ audit.status }})</li>
      </ul>
    </Modal>
    <Modal :show="showIncidents" @close="showIncidents = false">
      <h2 class="font-heading text-xl mb-4">Open Incidents</h2>
      <ul>
        <li v-for="incident in incidents" :key="incident.id">{{ incident.type }} - {{ incident.description }}</li>
      </ul>
    </Modal>
  </Layout>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import Layout from '../components/Layout.vue'
import Card from '../components/Card.vue'
import Modal from '../components/Modal.vue'
import Button from '../components/Button.vue'
import { Chart as ChartJS, ArcElement, BarElement, CategoryScale, LinearScale, Title, Tooltip, Legend } from 'chart.js'
import { Bar, Pie } from 'vue-chartjs'
import { supabase } from '../supabase'

ChartJS.register(ArcElement, BarElement, CategoryScale, LinearScale, Title, Tooltip, Legend)

const stats = ref({ users: 0, openAudits: 0, openIncidents: 0, auditCompletion: 0 })
const dateRange = ref({ start: '', end: '' })
const showUsers = ref(false)
const showAudits = ref(false)
const showIncidents = ref(false)
const users = ref<any[]>([])
const audits = ref<any[]>([])
const incidents = ref<any[]>([])

// Chart data
const auditBarData = ref({
  labels: ['Completed', 'Open'],
  datasets: [
    {
      label: 'Audits',
      backgroundColor: ['#34d399', '#f59e42'],
      data: [0, 0],
    },
  ],
})
const barOptions = { responsive: true, plugins: { legend: { display: false } } }
const incidentPieData = ref({
  labels: ['Resolved', 'Open'],
  datasets: [
    {
      backgroundColor: ['#60a5fa', '#f87171'],
      data: [0, 0],
    },
  ],
})
const pieOptions = { responsive: true }

async function fetchStats() {
  let userQuery = supabase.from('users').select('*', { count: 'exact', head: true })
  let auditQuery = supabase.from('audits').select('*', { count: 'exact', head: true })
  let incidentQuery = supabase.from('incidents').select('*', { count: 'exact', head: true })
  let allAuditsQuery = supabase.from('audits').select('status')
  let usersListQuery = supabase.from('users').select('id, name, email')
  let auditsListQuery = supabase.from('audits').select('id, title, status')
  let incidentsListQuery = supabase.from('incidents').select('id, type, description, status')

  if (dateRange.value.start) {
    userQuery = userQuery.gte('created_at', dateRange.value.start)
    usersListQuery = usersListQuery.gte('created_at', dateRange.value.start)
    auditQuery = auditQuery.gte('created_at', dateRange.value.start)
    auditsListQuery = auditsListQuery.gte('created_at', dateRange.value.start)
    incidentQuery = incidentQuery.gte('created_at', dateRange.value.start)
    incidentsListQuery = incidentsListQuery.gte('created_at', dateRange.value.start)
    allAuditsQuery = allAuditsQuery.gte('created_at', dateRange.value.start)
  }
  if (dateRange.value.end) {
    userQuery = userQuery.lte('created_at', dateRange.value.end)
    usersListQuery = usersListQuery.lte('created_at', dateRange.value.end)
    auditQuery = auditQuery.lte('created_at', dateRange.value.end)
    auditsListQuery = auditsListQuery.lte('created_at', dateRange.value.end)
    incidentQuery = incidentQuery.lte('created_at', dateRange.value.end)
    incidentsListQuery = incidentsListQuery.lte('created_at', dateRange.value.end)
    allAuditsQuery = allAuditsQuery.lte('created_at', dateRange.value.end)
  }

  const { count: userCount } = await userQuery
  const { count: openAudits } = await auditQuery.eq('status', 'open')
  const { count: openIncidents } = await incidentQuery.eq('status', 'open')
  const { data: allAudits } = await allAuditsQuery
  const completed = allAudits?.filter((a: any) => a.status === 'closed').length || 0
  const total = allAudits?.length || 0
  const auditCompletion = total > 0 ? Math.round((completed / total) * 100) : 0
  stats.value = {
    users: userCount || 0,
    openAudits: openAudits || 0,
    openIncidents: openIncidents || 0,
    auditCompletion,
  }
  const { data: usersData } = await usersListQuery
  const { data: auditsData } = await auditsListQuery.eq('status', 'open')
  const { data: incidentsData } = await incidentsListQuery.eq('status', 'open')
  users.value = usersData || []
  audits.value = auditsData || []
  incidents.value = incidentsData || []

  // Fetch audit completion for bar chart
  const { data: auditsAll } = await supabase.from('audits').select('status')
  const completedAudits = auditsAll?.filter((a: any) => a.status === 'closed').length || 0
  const openAuditsCount = auditsAll?.filter((a: any) => a.status === 'open').length || 0
  auditBarData.value.datasets[0].data = [completedAudits, openAuditsCount]

  // Fetch incident resolution for pie chart
  const { data: incidentsAll } = await supabase.from('incidents').select('status')
  const resolvedIncidents = incidentsAll?.filter((i: any) => i.status === 'closed').length || 0
  const openIncidentsPie = incidentsAll?.filter((i: any) => i.status === 'open').length || 0
  incidentPieData.value.datasets[0].data = [resolvedIncidents, openIncidentsPie]
}

onMounted(fetchStats)
</script>
