<template>
  <div class="bg-[#F9FAFB] min-h-screen">
    <!-- Page Header -->
    <div class="bg-white border-b border-gray-200 px-6 py-4 flex justify-between items-center">
      <h1 class="text-2xl font-semibold text-[#1F2937]">Audits</h1>
      
      <!-- Action Buttons -->
      <div class="flex space-x-3">
        <button 
          v-has-permission="'can_create_audits'"
          class="px-4 py-2 bg-[#0070F3] text-white rounded-md hover:bg-blue-600 transition-colors flex items-center"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-1" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z" clip-rule="evenodd" />
          </svg>
          New Audit
        </button>
        
        <button 
          class="px-4 py-2 border border-gray-300 text-[#1F2937] rounded-md hover:bg-gray-50 transition-colors flex items-center"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-1" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M3 3a1 1 0 011-1h12a1 1 0 011 1v3a1 1 0 01-.293.707L12 11.414V15a1 1 0 01-.293.707l-2 2A1 1 0 018 17v-5.586L3.293 6.707A1 1 0 013 6V3z" clip-rule="evenodd" />
          </svg>
          Filter
        </button>
      </div>
    </div>
    
    <!-- Main Content -->
    <div class="container mx-auto px-6 py-8">
      <div v-if="isLoading" class="flex justify-center my-12">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-[#0070F3]"></div>
      </div>
      
      <div v-else-if="audits.length === 0" class="bg-white rounded-lg shadow-md p-8 text-center">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-16 w-16 mx-auto text-gray-400 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
        <h3 class="text-xl font-medium text-[#1F2937] mb-2">No Audits Found</h3>
        <p class="text-gray-500 mb-6">There are no audits available at the moment.</p>
        <button 
          v-has-permission="'can_create_audits'"
          class="px-4 py-2 bg-[#0070F3] text-white rounded-md hover:bg-blue-600 transition-colors"
        >
          Create Your First Audit
        </button>
      </div>
      
      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div 
          v-for="audit in audits" 
          :key="audit.id" 
          class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow"
        >
          <div class="p-6">
            <div class="flex justify-between items-start mb-4">
              <h3 class="text-lg font-medium text-[#1F2937] line-clamp-2">{{ audit.title }}</h3>
              <span 
                class="px-2 py-1 text-xs rounded-full"
                :class="getStatusClass(audit.status)"
              >
                {{ formatStatus(audit.status) }}
              </span>
            </div>
            
            <p class="text-gray-500 mb-4 line-clamp-3">{{ audit.description }}</p>
            
            <div class="flex items-center text-sm text-gray-500 mb-4">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
              </svg>
              <span>{{ formatDate(audit.scheduled_date) }}</span>
            </div>
            
            <div class="border-t border-gray-100 pt-4 flex justify-between">
              <button 
                class="text-[#3B82F6] hover:text-blue-700"
                @click="viewAudit(audit.id)"
              >
                View Details
              </button>
              
              <div class="flex space-x-2">
                <button 
                  v-has-permission="'can_edit_audits'"
                  class="text-[#3B82F6] hover:text-blue-700"
                  @click="editAudit(audit.id)"
                >
                  Edit
                </button>
                
                <button 
                  v-has-permission="'can_assign_audits'"
                  class="text-[#3B82F6] hover:text-blue-700"
                  @click="assignAudit(audit.id)"
                >
                  Assign
                </button>
                
                <button 
                  v-has-permission="'can_close_audits'"
                  v-if="audit.status !== 'completed'"
                  class="text-[#10B981] hover:text-green-700"
                  @click="closeAudit(audit.id)"
                >
                  Close
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { supabase } from '../lib/supabaseClient';
import { permissionService } from '../services/permissionService';
import { format, parseISO } from 'date-fns';

// Import the permission directive
import hasPermissionDirective from '../directives/hasPermission';

const router = useRouter();
const isLoading = ref(true);
const audits = ref([]);

// Format date for display
function formatDate(dateString) {
  if (!dateString) return 'Not scheduled';
  return format(parseISO(dateString), 'MMM d, yyyy');
}

// Format status for display
function formatStatus(status) {
  switch (status) {
    case 'pending': return 'Pending';
    case 'in_progress': return 'In Progress';
    case 'completed': return 'Completed';
    default: return status;
  }
}

// Get CSS classes for status badge
function getStatusClass(status) {
  switch (status) {
    case 'pending': 
      return 'bg-[#3B82F6]/10 text-[#3B82F6]';
    case 'in_progress': 
      return 'bg-[#FF7A59]/10 text-[#FF7A59]';
    case 'completed': 
      return 'bg-[#10B981]/10 text-[#10B981]';
    default: 
      return 'bg-gray-100 text-gray-500';
  }
}

// Navigation functions
function viewAudit(id) {
  router.push(`/audits/${id}`);
}

function editAudit(id) {
  router.push(`/audits/${id}/edit`);
}

function assignAudit(id) {
  router.push(`/audits/${id}/assign`);
}

async function closeAudit(id) {
  try {
    const { error } = await supabase
      .from('audits')
      .update({ 
        status: 'completed',
        completion_date: new Date().toISOString()
      })
      .eq('id', id);
      
    if (error) throw error;
    
    // Refresh the audit in the list
    const updatedAudit = audits.value.find(a => a.id === id);
    if (updatedAudit) {
      updatedAudit.status = 'completed';
      updatedAudit.completion_date = new Date().toISOString();
    }
  } catch (error) {
    console.error('Error closing audit:', error);
    alert('Error closing audit: ' + error.message);
  }
}

// Load audits from database
async function loadAudits() {
  isLoading.value = true;
  
  try {
    const { data, error } = await supabase
      .from('audits')
      .select('*')
      .order('created_at', { ascending: false });
      
    if (error) throw error;
    
    audits.value = data || [];
  } catch (error) {
    console.error('Error loading audits:', error);
  } finally {
    isLoading.value = false;
  }
}

// Load data on component mount
onMounted(async () => {
  // Load user permissions first
  await permissionService.loadUserPermissions();
  
  // Then load audits
  await loadAudits();
});
</script>
