import { createRouter, createWebHistory } from 'vue-router';
import UnauthorizedPage from '../pages/UnauthorizedPage.vue';
import AuditsPage from '../pages/AuditsPage.vue';

// Define routes
const routes = [
  {
    path: '/',
    redirect: '/audits'
  },
  {
    path: '/audits',
    name: 'Audits',
    component: AuditsPage,
    meta: {
      requiresPermission: 'can_view_audits'
    }
  },
  {
    path: '/unauthorized',
    name: 'Unauthorized',
    component: UnauthorizedPage
  },
  // Add more routes as needed
];

// Create router instance
const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior() {
    // Always scroll to top
    return { top: 0 };
  }
});

export default router;
