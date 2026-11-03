import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      // Startsidan ritas av App.vue, så routen behöver ingen egen vy.
      path: '/',
      name: 'home',
      component: { render: () => null },
    },
    {
      path: '/teacher/statistics',
      name: 'teacher-statistics',
      component: () => import('../views/TeacherStatisticsView.vue'),
    },
    {
      path: '/achievements',
      name: 'achievements',
      component: () => import('../views/AchievementsView.vue'),
    },
  ],
})

export default router
