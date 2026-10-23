import { computed, ref } from 'vue'
import { defineStore } from 'pinia'
import { api } from '../api'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const status = ref('checking')
  const error = ref('')
  const version = ref(0)

  const isAuthenticated = computed(
    () => status.value === 'authenticated',
  )

  function setUser(value) {
    user.value = value
    status.value = value ? 'authenticated' : 'anonymous'
    error.value = ''
    version.value += 1
  }

  async function restore() {
    const startedAtVersion = version.value
    status.value = 'checking'
    error.value = ''

    try {
      const data = await api('/api/me')

      if (version.value !== startedAtVersion) return
      setUser(data.user)
    } catch (err) {
      if (version.value !== startedAtVersion) return

      if (err.status === 401) {
        setUser(null)
      } else {
        status.value = 'error'
        error.value = 'Kunde inte kontrollera inloggningen.'
      }
    }
  }

  async function login(username, password) {
    const data = await api('/api/login', {
      method: 'POST',
      body: { username, password },
    })

    setUser(data.user)
  }

  async function logout() {
    await api('/api/logout', { method: 'POST' })
    setUser(null)
  }

  function expire() {
    setUser(null)
  }

  return {
    user,
    status,
    error,
    version,
    isAuthenticated,
    restore,
    login,
    logout,
    expire,
  }
})
