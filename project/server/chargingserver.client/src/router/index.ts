import { createRouter, createWebHistory } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import LoginView from '@/views/LoginView.vue'
import UsersView from '@/views/UsersView.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', redirect: '/users' },
    { path: '/login', name: 'login', component: LoginView, meta: { public: true } },
    { path: '/users', name: 'users', component: UsersView },
  ],
})

router.beforeEach((to) => {
  const { isAuthenticated, isAdmin } = useAuth()
  if (to.meta.public) {
    if (isAuthenticated.value && isAdmin.value && to.name === 'login') {
      return { name: 'users' }
    }
    return true
  }

  if (!isAuthenticated.value || !isAdmin.value) {
    return { name: 'login' }
  }

  return true
})

export default router
