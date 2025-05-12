import { supabase } from '../lib/supabaseClient';
import { ref, computed } from 'vue';

// Reactive state for user permissions
const userGroups = ref([]);
const userPermissions = ref([]);
const groupPermissions = ref([]);
const isLoading = ref(true);
const error = ref(null);

// Computed property to get all effective permissions for the current user
const effectivePermissions = computed(() => {
  const permissions = new Map();
  
  // First add all group permissions
  userGroups.value.forEach(userGroup => {
    const groupId = userGroup.group_id;
    const groupPerms = groupPermissions.value.filter(gp => gp.group_id === groupId);
    
    groupPerms.forEach(gp => {
      permissions.set(gp.permission, true);
    });
  });
  
  // Then apply user-specific overrides
  userPermissions.value.forEach(up => {
    permissions.set(up.permission, up.granted);
  });
  
  return permissions;
});

/**
 * Load all permissions data for the current user
 */
async function loadUserPermissions() {
  isLoading.value = true;
  error.value = null;
  
  try {
    const { data: { user } } = await supabase.auth.getUser();
    
    if (!user) {
      throw new Error('User not authenticated');
    }
    
    // Get user's groups
    const { data: userGroupsData, error: userGroupsError } = await supabase
      .from('user_groups')
      .select('*')
      .eq('user_id', user.id);
      
    if (userGroupsError) throw userGroupsError;
    userGroups.value = userGroupsData || [];
    
    // Get all group permissions for the user's groups
    if (userGroups.value.length > 0) {
      const groupIds = userGroups.value.map(ug => ug.group_id);
      
      const { data: groupPermsData, error: groupPermsError } = await supabase
        .from('group_permissions')
        .select('*')
        .in('group_id', groupIds);
        
      if (groupPermsError) throw groupPermsError;
      groupPermissions.value = groupPermsData || [];
    }
    
    // Get user-specific permission overrides
    const { data: userPermsData, error: userPermsError } = await supabase
      .from('user_permissions')
      .select('*')
      .eq('user_id', user.id);
      
    if (userPermsError) throw userPermsError;
    userPermissions.value = userPermsData || [];
    
  } catch (err) {
    console.error('Error loading permissions:', err);
    error.value = err.message;
  } finally {
    isLoading.value = false;
  }
}

/**
 * Check if the current user has a specific permission
 * @param {string} permission - The permission to check
 * @returns {boolean} - Whether the user has the permission
 */
function hasPermission(permission) {
  if (isLoading.value) {
    console.warn('Permissions still loading, defaulting to false');
    return false;
  }
  
  return effectivePermissions.value.get(permission) === true;
}

/**
 * Get all groups for the system
 * @returns {Promise<Array>} - Array of all groups
 */
async function getAllGroups() {
  const { data, error: groupsError } = await supabase
    .from('groups')
    .select('*')
    .order('name');
    
  if (groupsError) {
    console.error('Error fetching groups:', groupsError);
    throw groupsError;
  }
  
  return data || [];
}

/**
 * Get all permissions for a specific group
 * @param {string} groupId - The group ID to get permissions for
 * @returns {Promise<Array>} - Array of permissions for the group
 */
async function getGroupPermissions(groupId) {
  const { data, error: permsError } = await supabase
    .from('group_permissions')
    .select('*')
    .eq('group_id', groupId);
    
  if (permsError) {
    console.error('Error fetching group permissions:', permsError);
    throw permsError;
  }
  
  return data || [];
}

/**
 * Assign a user to a group
 * @param {string} userId - The user ID to assign
 * @param {string} groupId - The group ID to assign the user to
 * @returns {Promise<void>}
 */
async function assignUserToGroup(userId, groupId) {
  const { error } = await supabase
    .from('user_groups')
    .insert([{ user_id: userId, group_id: groupId }]);
    
  if (error) {
    console.error('Error assigning user to group:', error);
    throw error;
  }
  
  // Reload permissions if this is for the current user
  const { data: { user } } = await supabase.auth.getUser();
  if (user && user.id === userId) {
    await loadUserPermissions();
  }
}

/**
 * Remove a user from a group
 * @param {string} userId - The user ID to remove
 * @param {string} groupId - The group ID to remove the user from
 * @returns {Promise<void>}
 */
async function removeUserFromGroup(userId, groupId) {
  const { error } = await supabase
    .from('user_groups')
    .delete()
    .eq('user_id', userId)
    .eq('group_id', groupId);
    
  if (error) {
    console.error('Error removing user from group:', error);
    throw error;
  }
  
  // Reload permissions if this is for the current user
  const { data: { user } } = await supabase.auth.getUser();
  if (user && user.id === userId) {
    await loadUserPermissions();
  }
}

/**
 * Set a user-specific permission override
 * @param {string} userId - The user ID to set the override for
 * @param {string} permission - The permission to override
 * @param {boolean} granted - Whether to grant or deny the permission
 * @returns {Promise<void>}
 */
async function setUserPermission(userId, permission, granted) {
  // Use upsert to handle both insert and update cases
  const { error } = await supabase
    .from('user_permissions')
    .upsert([
      { 
        user_id: userId, 
        permission, 
        granted
      }
    ], { 
      onConflict: 'user_id,permission',
      ignoreDuplicates: false
    });
    
  if (error) {
    console.error('Error setting user permission:', error);
    throw error;
  }
  
  // Reload permissions if this is for the current user
  const { data: { user } } = await supabase.auth.getUser();
  if (user && user.id === userId) {
    await loadUserPermissions();
  }
}

/**
 * Remove a user-specific permission override
 * @param {string} userId - The user ID to remove the override for
 * @param {string} permission - The permission to remove the override for
 * @returns {Promise<void>}
 */
async function removeUserPermission(userId, permission) {
  const { error } = await supabase
    .from('user_permissions')
    .delete()
    .eq('user_id', userId)
    .eq('permission', permission);
    
  if (error) {
    console.error('Error removing user permission:', error);
    throw error;
  }
  
  // Reload permissions if this is for the current user
  const { data: { user } } = await supabase.auth.getUser();
  if (user && user.id === userId) {
    await loadUserPermissions();
  }
}

export const permissionService = {
  // State
  userGroups,
  userPermissions,
  groupPermissions,
  isLoading,
  error,
  effectivePermissions,
  
  // Methods
  loadUserPermissions,
  hasPermission,
  getAllGroups,
  getGroupPermissions,
  assignUserToGroup,
  removeUserFromGroup,
  setUserPermission,
  removeUserPermission
};
