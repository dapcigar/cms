import { createRouter, createWebHistory } from 'vue-router';
import { supabase } from './supabase';
import Login from './pages/Login.vue';
import Signup from './pages/Signup.vue';
import Dashboard from './pages/Dashboard.vue';

const routes = [
  {
    path: '/',
    name: 'Login',
    component: Login,
    meta: { requiresGuest: true }
  },
  {
    path: '/signup',
    name: 'Signup',
    component: Signup,
    meta: { requiresGuest: true }
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: Dashboard,
    meta: { requiresAuth: true }
  },
  {
    path: '/users',
    name: 'Users',
    component: () => import('./pages/Users.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/audits',
    name: 'Audits',
    component: () => import('./pages/Audits.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/audits/new',
    name: 'AuditCreateForm',
    component: () => import('./pages/AuditForm.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/audits/:id',
    name: 'AuditDetail',
    component: () => import('./pages/AuditDetail.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/action-plans',
    name: 'ActionPlans',
    component: () => import('./pages/ActionPlans.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/safeguarding',
    name: 'Safeguarding',
    component: () => import('./pages/Safeguarding.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/safeguarding/new',
    name: 'SafeguardingLogForm',
    component: () => import('./pages/SafeguardingLogForm.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/incidents',
    name: 'Incidents',
    component: () => import('./pages/Incidents.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/incidents/new',
    name: 'IncidentCreateForm',
    component: () => import('./pages/IncidentForm.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/surveys',
    name: 'Surveys',
    component: () => import('./pages/Surveys.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/analytics',
    name: 'Analytics',
    component: () => import('./pages/Analytics.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/notifications',
    name: 'Notifications',
    component: () => import('./pages/Notifications.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/settings',
    name: 'Settings',
    component: () => import('./pages/Settings.vue'),
    meta: { requiresAuth: true }
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

router.beforeEach(async (to, from, next) => {
  const { data: { session } } = await supabase.auth.getSession();
  const requiresAuth = to.matched.some(record => record.meta.requiresAuth);
  const requiresGuest = to.matched.some(record => record.meta.requiresGuest);

  if (requiresAuth && !session) {
    next('/');
  } else if (requiresGuest && session) {
    next('/dashboard');
  } else {
    next();
  }
});

export default router;
