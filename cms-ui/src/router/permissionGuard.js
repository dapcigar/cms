import { permissionService } from '../services/permissionService';

/**
 * Navigation guard for Vue Router to check if user has required permissions
 * 
 * Usage in route definition:
 * {
 *   path: '/audits',
 *   component: AuditsPage,
 *   meta: {
 *     requiresPermission: 'can_view_audits'
 *   }
 * }
 * 
 * @param {Object} to - Route the user is navigating to
 * @param {Object} from - Route the user is navigating from
 * @param {Function} next - Function to resolve the hook
 */
export async function permissionGuard(to, from, next) {
  // Skip if route doesn't require permission
  if (!to.meta.requiresPermission) {
    return next();
  }
  
  // Make sure permissions are loaded
  if (permissionService.isLoading.value) {
    try {
      await permissionService.loadUserPermissions();
    } catch (error) {
      console.error('Error loading permissions:', error);
      // Redirect to login if permissions can't be loaded
      return next({ path: '/login', query: { redirect: to.fullPath } });
    }
  }
  
  // Check if user has required permission
  const requiredPermission = to.meta.requiresPermission;
  const hasPermission = permissionService.hasPermission(requiredPermission);
  
  if (hasPermission) {
    next();
  } else {
    // Redirect to unauthorized page or home
    next({ path: '/unauthorized', query: { redirect: to.fullPath } });
  }
}

/**
 * Setup permission guard for Vue Router
 * @param {Object} router - Vue Router instance
 */
export function setupPermissionGuard(router) {
  router.beforeEach(permissionGuard);
}
