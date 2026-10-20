import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView,
    },
    {
      path: '/about',
      name: 'about',
      // route level code-splitting
      // this generates a separate chunk (About.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: () => import('../views/AboutView.vue'),
    },
    {
      path: '/achievements',
      name: 'achievements',
      component: () => import('../views/AchievementsView.vue'),
    },
    {
      path: '/teachers',
      name: 'teachers',
      component: () => import('../views/teacherView.vue'),
      beforeEnter: (to, from) => {
        const savedUser = JSON.parse(localStorage.getItem('user'));
        if (savedUser && savedUser.role === 'teacher') {
          return true; 
        } else {
          return '/'; 
        }
      }
    }
  ],
})

export default router
