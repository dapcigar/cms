import { createApp } from 'vue'
import './index.css'
import './assets/styles.css'
import App from './App.vue'
import router from './router'

// Import permission system
import hasPermissionDirective from './directives/hasPermission'
import { setupPermissionGuard } from './router/permissionGuard'
import { permissionService } from './services/permissionService'

// Setup permission guard for router
setupPermissionGuard(router)

// Create app instance
const app = createApp(App)

// Register plugins and directives
app.use(router)
app.use(hasPermissionDirective)

// Make permission service available globally
app.config.globalProperties.$permissions = permissionService

// Mount the app
app.mount('#app')
