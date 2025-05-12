import { permissionService } from '../services/permissionService';
import { watch } from 'vue';

/**
 * Vue directive to conditionally render elements based on user permissions
 * 
 * Usage:
 * <button v-has-permission="'can_edit_audits'">Edit Audit</button>
 * <div v-has-permission:not="'can_delete_audits'">Cannot delete audits</div>
 */
export const hasPermission = {
  mounted(el, binding) {
    const { value, modifiers, arg } = binding;
    
    // Make sure permissions are loaded
    if (permissionService.isLoading.value) {
      // Hide element until permissions are loaded
      el.style.display = 'none';
      
      // Watch for permissions to load
      const unwatch = watch(permissionService.isLoading, isLoading => {
        if (!isLoading) {
          checkPermission();
          unwatch();
        }
      });
    } else {
      checkPermission();
    }
    
    function checkPermission() {
      const hasRequiredPermission = permissionService.hasPermission(value);
      
      // If arg is 'not', invert the check (show when user DOESN'T have permission)
      const shouldDisplay = arg === 'not' ? !hasRequiredPermission : hasRequiredPermission;
      
      if (!shouldDisplay) {
        // If using 'hidden' modifier, just hide the element
        if (modifiers.hidden) {
          el.style.display = 'none';
        } 
        // Otherwise remove it from the DOM
        else {
          el.parentNode?.removeChild(el);
        }
      }
    }
  }
};

/**
 * Register the directive with Vue
 */
export default {
  install(app) {
    app.directive('has-permission', hasPermission);
  }
};
