import { computed, ref, watch } from 'vue'
import { defineStore } from 'pinia'
import { api } from '../api'
import { useAuthStore } from './auth'

export const useAchievementsStore = defineStore('achievements', () => {
  const auth = useAuthStore()

  const achievements = ref([])
  const statistics = ref(null)
  const loading = ref(false)
  const error = ref('')

  let requestVersion = 0

  function reset() {
    requestVersion += 1
    achievements.value = []
    statistics.value = null
    loading.value = false
    error.value = ''
  }

  async function load() {
    if (!auth.isAuthenticated) {
      reset()
      return
    }

    const currentRequest = ++requestVersion
    const accountVersion = auth.version

    loading.value = true
    error.value = ''

    const isCurrent = () =>
      currentRequest === requestVersion &&
      accountVersion === auth.version

    try {
      const data = await api('/api/me/achievements')

      if (!isCurrent()) return

      if (data.userId !== auth.user?.id) {
        reset()
        await auth.restore()
        return
      }

      achievements.value = data.achievements
      statistics.value = data.statistics
    } catch (err) {
      if (!isCurrent()) return

      if (err.status === 401) {
        auth.expire()
      } else {
        error.value = 'Kunde inte hämta utmärkelserna.'
      }
    } finally {
      if (isCurrent()) loading.value = false
    }
  }

  watch(() => auth.version, reset, { flush: 'sync' })

  const unlockedCount = computed(
    () => achievements.value.filter((item) => item.unlocked).length,
  )

  return {
    achievements,
    statistics,
    loading,
    error,
    unlockedCount,
    load,
    reset,
  }
})
