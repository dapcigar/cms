<template>
  <div class="audit-templates">
    <!-- Header with create button -->
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-2xl font-bold text-slate-800">Audit Templates</h1>
      <button 
        @click="showCreateTemplate = true"
        class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md"
      >
        Create Template
      </button>
    </div>

    <!-- Template creation modal -->
    <Modal v-model="showCreateTemplate">
      <TemplateForm 
        @submit="createTemplate" 
        @cancel="showCreateTemplate = false" 
      />
    </Modal>

    <!-- Templates list -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <TemplateCard 
        v-for="template in templates" 
        :key="template.id"
        :template="template"
        @edit="editTemplate"
        @delete="confirmDeleteTemplate"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '../supabase'
import Modal from '../components/Modal.vue'
import TemplateForm from '../components/audit/TemplateForm.vue'
import TemplateCard from '../components/audit/TemplateCard.vue'

const showCreateTemplate = ref(false)
const templates = ref<any[]>([])

// Fetch templates from Supabase
async function fetchTemplates() {
  const { data, error } = await supabase
    .from('audit_templates')
    .select('*')
    .order('created_at', { ascending: false })
    
  if (error) {
    console.error('Error fetching templates:', error)
    return
  }
  
  templates.value = data
}

// Create new template
async function createTemplate(templateData: any) {
  const { data, error } = await supabase
    .from('audit_templates')
    .insert([templateData])
    .select()
    
  if (error) {
    console.error('Error creating template:', error)
    return
  }
  
  templates.value.unshift(data[0])
  showCreateTemplate.value = false
}

// Initialize component
onMounted(() => {
  fetchTemplates()
})
</script>

<style scoped>
.audit-templates {
  @apply p-6;
}
</style>
