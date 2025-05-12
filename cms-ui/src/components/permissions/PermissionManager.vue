<template>
  <div class="bg-[#F9FAFB] rounded-lg shadow-md p-6">
    <h2 class="text-2xl font-semibold text-[#1F2937] mb-6">Permission Management</h2>
    
    <div class="mb-6">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-xl font-medium text-[#1F2937]">User Groups</h3>
        <button 
          @click="showAddGroupModal = true" 
          class="bg-[#0070F3] text-white px-4 py-2 rounded-md hover:bg-blue-600 transition-colors"
        >
          Add Group
        </button>
      </div>
      
      <div v-if="isLoading" class="flex justify-center my-8">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-[#0070F3]"></div>
      </div>
      
      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div 
          v-for="group in groups" 
          :key="group.id" 
          class="bg-white border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow"
        >
          <div class="flex justify-between items-start mb-2">
            <h4 class="text-lg font-medium text-[#1F2937]">{{ group.name }}</h4>
            <button 
              @click="editGroup(group)" 
              class="text-[#3B82F6] hover:text-blue-700"
            >
              Edit
            </button>
          </div>
          <p class="text-sm text-gray-500 mb-3">{{ group.description }}</p>
          <div class="mt-2">
            <h5 class="text-sm font-medium text-[#1F2937] mb-1">Permissions:</h5>
            <div class="flex flex-wrap gap-1">
              <span 
                v-for="perm in groupPermissionsMap[group.id]" 
                :key="perm.id" 
                class="inline-flex items-center px-2 py-1 bg-[#F9FAFB] text-xs rounded-full"
              >
                {{ formatPermission(perm.permission) }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <div class="border-t border-gray-200 pt-6 mt-6">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-xl font-medium text-[#1F2937]">User Permissions</h3>
        <button 
          @click="showUserPermModal = true" 
          class="bg-[#0070F3] text-white px-4 py-2 rounded-md hover:bg-blue-600 transition-colors"
        >
          Manage User Permissions
        </button>
      </div>
      
      <div v-if="isLoading" class="flex justify-center my-8">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-[#0070F3]"></div>
      </div>
      
      <div v-else-if="users.length === 0" class="text-center py-8 text-gray-500">
        No users found
      </div>
      
      <div v-else class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-[#F9FAFB]">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-[#1F2937] uppercase tracking-wider">User</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-[#1F2937] uppercase tracking-wider">Groups</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-[#1F2937] uppercase tracking-wider">Custom Permissions</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-[#1F2937] uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="user in users" :key="user.id">
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center">
                  <div>
                    <div class="text-sm font-medium text-[#1F2937]">{{ user.name || 'Unnamed User' }}</div>
                    <div class="text-sm text-gray-500">{{ user.email }}</div>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex flex-wrap gap-1">
                  <span 
                    v-for="userGroup in getUserGroups(user.id)" 
                    :key="userGroup.id" 
                    class="inline-flex items-center px-2 py-1 bg-[#F9FAFB] text-xs rounded-full"
                  >
                    {{ getGroupName(userGroup.group_id) }}
                  </span>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex flex-wrap gap-1">
                  <span 
                    v-for="perm in getUserPermissions(user.id)" 
                    :key="perm.id" 
                    class="inline-flex items-center px-2 py-1 text-xs rounded-full"
                    :class="perm.granted ? 'bg-[#10B981]/10 text-[#10B981]' : 'bg-[#EF4444]/10 text-[#EF4444]'"
                  >
                    {{ formatPermission(perm.permission) }} {{ perm.granted ? '✓' : '✗' }}
                  </span>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm">
                <button 
                  @click="editUserPermissions(user)" 
                  class="text-[#3B82F6] hover:text-blue-700 mr-3"
                >
                  Edit
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    
    <!-- Group Modal -->
    <div v-if="showAddGroupModal || editingGroup" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg shadow-xl p-6 w-full max-w-md">
        <h3 class="text-xl font-medium text-[#1F2937] mb-4">
          {{ editingGroup ? 'Edit Group' : 'Add New Group' }}
        </h3>
        
        <form @submit.prevent="saveGroup">
          <div class="mb-4">
            <label class="block text-sm font-medium text-[#1F2937] mb-1">Group Name</label>
            <input 
              v-model="groupForm.name" 
              type="text" 
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#0070F3]"
              required
            />
          </div>
          
          <div class="mb-4">
            <label class="block text-sm font-medium text-[#1F2937] mb-1">Description</label>
            <textarea 
              v-model="groupForm.description" 
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#0070F3]"
              rows="3"
            ></textarea>
          </div>
          
          <div class="mb-4">
            <label class="block text-sm font-medium text-[#1F2937] mb-1">Permissions</label>
            <div class="space-y-2 mt-2">
              <div 
                v-for="perm in availablePermissions" 
                :key="perm" 
                class="flex items-center"
              >
                <input 
                  :id="perm" 
                  type="checkbox" 
                  :value="perm" 
                  v-model="groupForm.permissions" 
                  class="h-4 w-4 text-[#0070F3] focus:ring-[#0070F3] border-gray-300 rounded"
                />
                <label :for="perm" class="ml-2 block text-sm text-[#1F2937]">
                  {{ formatPermission(perm) }}
                </label>
              </div>
            </div>
          </div>
          
          <div class="flex justify-end space-x-3 mt-6">
            <button 
              type="button" 
              @click="closeGroupModal" 
              class="px-4 py-2 border border-gray-300 rounded-md text-[#1F2937] hover:bg-gray-50"
            >
              Cancel
            </button>
            <button 
              type="submit" 
              class="px-4 py-2 bg-[#0070F3] text-white rounded-md hover:bg-blue-600"
            >
              {{ editingGroup ? 'Update' : 'Create' }}
            </button>
          </div>
        </form>
      </div>
    </div>
    
    <!-- User Permissions Modal -->
    <div v-if="showUserPermModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg shadow-xl p-6 w-full max-w-2xl">
        <h3 class="text-xl font-medium text-[#1F2937] mb-4">
          Manage User Permissions
        </h3>
        
        <div class="mb-4">
          <label class="block text-sm font-medium text-[#1F2937] mb-1">Select User</label>
          <select 
            v-model="selectedUserId" 
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#0070F3]"
          >
            <option value="">Select a user</option>
            <option v-for="user in users" :key="user.id" :value="user.id">
              {{ user.name || user.email }}
            </option>
          </select>
        </div>
        
        <div v-if="selectedUserId" class="space-y-6">
          <div>
            <h4 class="text-lg font-medium text-[#1F2937] mb-2">Group Membership</h4>
            <div class="space-y-2">
              <div 
                v-for="group in groups" 
                :key="group.id" 
                class="flex items-center"
              >
                <input 
                  :id="`group-${group.id}`" 
                  type="checkbox" 
                  :value="group.id" 
                  v-model="userForm.groups" 
                  class="h-4 w-4 text-[#0070F3] focus:ring-[#0070F3] border-gray-300 rounded"
                />
                <label :for="`group-${group.id}`" class="ml-2 block text-sm text-[#1F2937]">
                  {{ group.name }}
                </label>
              </div>
            </div>
          </div>
          
          <div>
            <h4 class="text-lg font-medium text-[#1F2937] mb-2">Permission Overrides</h4>
            <p class="text-sm text-gray-500 mb-3">
              These settings will override the permissions granted by groups.
            </p>
            
            <div class="space-y-2">
              <div 
                v-for="perm in availablePermissions" 
                :key="perm" 
                class="flex items-center space-x-2"
              >
                <select 
                  v-model="userForm.permissions[perm]" 
                  class="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-[#0070F3]"
                >
                  <option value="inherit">Inherit from groups</option>
                  <option value="grant">Explicitly grant</option>
                  <option value="deny">Explicitly deny</option>
                </select>
                <label class="block text-sm text-[#1F2937]">
                  {{ formatPermission(perm) }}
                </label>
              </div>
            </div>
          </div>
        </div>
        
        <div class="flex justify-end space-x-3 mt-6">
          <button 
            type="button" 
            @click="showUserPermModal = false" 
            class="px-4 py-2 border border-gray-300 rounded-md text-[#1F2937] hover:bg-gray-50"
          >
            Cancel
          </button>
          <button 
            @click="saveUserPermissions" 
            :disabled="!selectedUserId"
            class="px-4 py-2 bg-[#0070F3] text-white rounded-md hover:bg-blue-600 disabled:bg-gray-300 disabled:cursor-not-allowed"
          >
            Save
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { supabase } from '../../lib/supabaseClient';
import { permissionService } from '../../services/permissionService';

// State
const isLoading = ref(true);
const groups = ref([]);
const groupPermissions = ref([]);
const userGroups = ref([]);
const userPermissions = ref([]);
const users = ref([]);

// Group form state
const showAddGroupModal = ref(false);
const editingGroup = ref(null);
const groupForm = ref({
  name: '',
  description: '',
  permissions: []
});

// User permissions form state
const showUserPermModal = ref(false);
const selectedUserId = ref('');
const userForm = ref({
  groups: [],
  permissions: {}
});

// Available permissions
const availablePermissions = [
  'can_view_audits',
  'can_edit_audits',
  'can_assign_audits',
  'can_close_audits',
  'can_create_audits',
  'can_delete_audits'
];

// Computed properties
const groupPermissionsMap = computed(() => {
  const map = {};
  groupPermissions.value.forEach(perm => {
    if (!map[perm.group_id]) {
      map[perm.group_id] = [];
    }
    map[perm.group_id].push(perm);
  });
  return map;
});

// Methods
function formatPermission(permission) {
  return permission
    .replace('can_', '')
    .split('_')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ');
}

function getUserGroups(userId) {
  return userGroups.value.filter(ug => ug.user_id === userId);
}

function getUserPermissions(userId) {
  return userPermissions.value.filter(up => up.user_id === userId);
}

function getGroupName(groupId) {
  const group = groups.value.find(g => g.id === groupId);
  return group ? group.name : 'Unknown Group';
}

function editGroup(group) {
  editingGroup.value = group;
  groupForm.value = {
    name: group.name,
    description: group.description,
    permissions: groupPermissionsMap.value[group.id]?.map(p => p.permission) || []
  };
}

function closeGroupModal() {
  showAddGroupModal.value = false;
  editingGroup.value = null;
  groupForm.value = {
    name: '',
    description: '',
    permissions: []
  };
}

async function saveGroup() {
  try {
    if (editingGroup.value) {
      // Update existing group
      const { error } = await supabase
        .from('groups')
        .update({
          name: groupForm.value.name,
          description: groupForm.value.description
        })
        .eq('id', editingGroup.value.id);
        
      if (error) throw error;
      
      // Delete existing permissions
      const { error: deleteError } = await supabase
        .from('group_permissions')
        .delete()
        .eq('group_id', editingGroup.value.id);
        
      if (deleteError) throw deleteError;
      
      // Add new permissions
      if (groupForm.value.permissions.length > 0) {
        const permissionsToInsert = groupForm.value.permissions.map(permission => ({
          group_id: editingGroup.value.id,
          permission
        }));
        
        const { error: insertError } = await supabase
          .from('group_permissions')
          .insert(permissionsToInsert);
          
        if (insertError) throw insertError;
      }
    } else {
      // Create new group
      const { data, error } = await supabase
        .from('groups')
        .insert({
          name: groupForm.value.name,
          description: groupForm.value.description
        })
        .select()
        .single();
        
      if (error) throw error;
      
      // Add permissions
      if (groupForm.value.permissions.length > 0) {
        const permissionsToInsert = groupForm.value.permissions.map(permission => ({
          group_id: data.id,
          permission
        }));
        
        const { error: insertError } = await supabase
          .from('group_permissions')
          .insert(permissionsToInsert);
          
        if (insertError) throw insertError;
      }
    }
    
    // Reload data
    await loadData();
    closeGroupModal();
  } catch (error) {
    console.error('Error saving group:', error);
    alert('Error saving group: ' + error.message);
  }
}

function editUserPermissions(user) {
  selectedUserId.value = user.id;
  
  // Set groups
  const userGroupIds = getUserGroups(user.id).map(ug => ug.group_id);
  userForm.value.groups = userGroupIds;
  
  // Set permission overrides
  userForm.value.permissions = {};
  availablePermissions.forEach(perm => {
    userForm.value.permissions[perm] = 'inherit';
  });
  
  // Apply existing overrides
  const userPerms = getUserPermissions(user.id);
  userPerms.forEach(up => {
    userForm.value.permissions[up.permission] = up.granted ? 'grant' : 'deny';
  });
  
  showUserPermModal.value = true;
}

async function saveUserPermissions() {
  if (!selectedUserId.value) return;
  
  try {
    // Handle group assignments
    const currentUserGroups = getUserGroups(selectedUserId.value);
    const currentGroupIds = currentUserGroups.map(ug => ug.group_id);
    
    // Groups to add
    const groupsToAdd = userForm.value.groups.filter(groupId => !currentGroupIds.includes(groupId));
    
    // Groups to remove
    const groupsToRemove = currentGroupIds.filter(groupId => !userForm.value.groups.includes(groupId));
    
    // Add new group assignments
    if (groupsToAdd.length > 0) {
      const groupAssignments = groupsToAdd.map(groupId => ({
        user_id: selectedUserId.value,
        group_id: groupId
      }));
      
      const { error } = await supabase
        .from('user_groups')
        .insert(groupAssignments);
        
      if (error) throw error;
    }
    
    // Remove group assignments
    for (const groupId of groupsToRemove) {
      const { error } = await supabase
        .from('user_groups')
        .delete()
        .eq('user_id', selectedUserId.value)
        .eq('group_id', groupId);
        
      if (error) throw error;
    }
    
    // Handle permission overrides
    const permOverrides = Object.entries(userForm.value.permissions);
    
    // Remove all existing overrides first
    const { error: deleteError } = await supabase
      .from('user_permissions')
      .delete()
      .eq('user_id', selectedUserId.value);
      
    if (deleteError) throw deleteError;
    
    // Add new overrides
    const overridesToInsert = permOverrides
      .filter(([_, value]) => value !== 'inherit')
      .map(([permission, value]) => ({
        user_id: selectedUserId.value,
        permission,
        granted: value === 'grant'
      }));
      
    if (overridesToInsert.length > 0) {
      const { error } = await supabase
        .from('user_permissions')
        .insert(overridesToInsert);
        
      if (error) throw error;
    }
    
    // Reload data
    await loadData();
    showUserPermModal.value = false;
    selectedUserId.value = '';
    userForm.value = {
      groups: [],
      permissions: {}
    };
  } catch (error) {
    console.error('Error saving user permissions:', error);
    alert('Error saving user permissions: ' + error.message);
  }
}

// Data loading
async function loadData() {
  isLoading.value = true;
  
  try {
    // Load groups
    const { data: groupsData, error: groupsError } = await supabase
      .from('groups')
      .select('*')
      .order('name');
      
    if (groupsError) throw groupsError;
    groups.value = groupsData || [];
    
    // Load group permissions
    const { data: groupPermsData, error: groupPermsError } = await supabase
      .from('group_permissions')
      .select('*');
      
    if (groupPermsError) throw groupPermsError;
    groupPermissions.value = groupPermsData || [];
    
    // Load users
    const { data: profilesData, error: profilesError } = await supabase
      .from('profiles')
      .select('*');
      
    if (profilesError) throw profilesError;
    users.value = profilesData || [];
    
    // Load user groups
    const { data: userGroupsData, error: userGroupsError } = await supabase
      .from('user_groups')
      .select('*');
      
    if (userGroupsError) throw userGroupsError;
    userGroups.value = userGroupsData || [];
    
    // Load user permissions
    const { data: userPermsData, error: userPermsError } = await supabase
      .from('user_permissions')
      .select('*');
      
    if (userPermsError) throw userPermsError;
    userPermissions.value = userPermsData || [];
  } catch (error) {
    console.error('Error loading data:', error);
  } finally {
    isLoading.value = false;
  }
}

// Watch for changes to selectedUserId
watch(selectedUserId, (newValue) => {
  if (!newValue) {
    userForm.value = {
      groups: [],
      permissions: {}
    };
  }
});

// Load data on component mount
onMounted(async () => {
  await loadData();
  
  // Also load the current user's permissions for the permission service
  await permissionService.loadUserPermissions();
});
</script>
