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
  const icons = {
    FIRST_ANSWER: '🌱',
    TEN_CORRECT: '🧠',
    TEN_UNIQUE_CORRECT: '🧭',
    THREE_IN_A_ROW: '🔥',
    HISTORICAL_CHALLENGER: '🏛️',
  }

  let requestVersion = 0
  let hasLoaded = false

  function reset() {
    requestVersion += 1
    hasLoaded = false
    achievements.value = []
    statistics.value = null
    loading.value = false
    error.value = ''
  }

  async function load() {
    if (!auth.isAuthenticated) {
      reset()
      return []
    }

    const currentRequest = ++requestVersion
    const accountVersion = auth.version

    loading.value = true
    error.value = ''

    const isCurrent = () => currentRequest === requestVersion && accountVersion === auth.version

    try {
      const data = await api('/api/me/achievements')

      if (!isCurrent()) return []

      if (data.userId !== auth.user?.id) {
        reset()
        await auth.restore()
        return []
      }

      const previouslyUnlocked = new Set(
        achievements.value.filter((item) => item.unlocked).map((item) => item.code)
      )
      const hadBaseline = hasLoaded

      achievements.value = data.achievements.map((item) => ({
        ...item,
        icon: icons[item.code] ?? '🏅',
      }))
      statistics.value = data.statistics
      hasLoaded = true

      // Serverns tilldelningar avgör vad som är upplåst.
      // Första hämtningen är en baslinje, inte en lista med nya utmärkelser.
      return hadBaseline
        ? achievements.value.filter((item) => item.unlocked && !previouslyUnlocked.has(item.code))
        : []
    } catch (err) {
      if (!isCurrent()) return []

      if (err.status === 401) {
        auth.expire()
      } else {
        error.value = 'Kunde inte hämta utmärkelserna.'
      }
      return []
    } finally {
      if (isCurrent()) loading.value = false
    }
  }

  watch(() => auth.version, reset, { flush: 'sync' })

  const unlockedCount = computed(() => achievements.value.filter((item) => item.unlocked).length)

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
