import { computed, ref } from 'vue'
import { defineStore } from 'pinia'
import { api } from '../api'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const status = ref('checking')
  const error = ref('')
  const version = ref(0)
  const busy = ref(false)
  let operation = 0

  const isAuthenticated = computed(() => status.value === 'authenticated')

  function setUser(value) {
    user.value = value
    status.value = value ? 'authenticated' : 'anonymous'
    error.value = ''
    version.value += 1
  }

  async function restore() {
    if (busy.value) return
    const currentOperation = ++operation
    status.value = 'checking'
    error.value = ''

    try {
      const data = await api('/api/me')

      if (operation !== currentOperation) return
      setUser(data.user)
    } catch (err) {
      if (operation !== currentOperation) return

      if (err.status === 401) {
        setUser(null)
      } else {
        user.value = null
        version.value += 1
        status.value = 'error'
        error.value = 'Kunde inte kontrollera inloggningen.'
      }
    }
  }

  async function login(username, password) {
    if (busy.value) throw new Error('Ett kontoanrop pågår redan.')
    const currentOperation = ++operation
    busy.value = true
    try {
      const data = await api('/api/login', {
        method: 'POST',
        body: { username, password },
      })
      if (operation === currentOperation) setUser(data.user)
    } catch (err) {
      // Vid ett tappat nätverkssvar kan servern ändå ha ändrat cookien.
      if (!err.status || err.status >= 500) {
        user.value = null
        status.value = 'error'
        error.value = 'Kunde inte bekräfta inloggningen. Kontrollera igen.'
        version.value += 1
      }
      throw err
    } finally {
      busy.value = false
    }
  }

  async function logout() {
    if (busy.value) throw new Error('Ett kontoanrop pågår redan.')
    ++operation
    busy.value = true
    try {
      await api('/api/logout', { method: 'POST' })
      setUser(null)
    } finally {
      busy.value = false
    }
  }

  function expire() {
    ++operation
    setUser(null)
  }

  return {
    user,
    status,
    error,
    version,
    busy,
    isAuthenticated,
    restore,
    login,
    logout,
    expire,
  }
})
