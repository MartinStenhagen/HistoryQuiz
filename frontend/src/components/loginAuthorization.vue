<script setup>
import { reactive, ref } from 'vue'
import { useAuthStore } from '../stores/auth'

const props = defineProps({ disabled: { type: Boolean, default: false } })
const emit = defineEmits(['login-success'])
const auth = useAuthStore()
const formData = reactive({ username: '', password: '' })
const errorMessage = ref('')

async function handleLogin() {
  if (props.disabled || auth.busy) return
  errorMessage.value = ''
  try {
    await auth.login(formData.username, formData.password)
    formData.password = ''
    emit('login-success', auth.user)
  } catch (error) {
    errorMessage.value = error.message || 'Kunde inte logga in.'
  }
}
</script>

<template>
  <section class="login-container">
    <form @submit.prevent="handleLogin">
      <label class="login_label">
        Användarnamn
        <input
          class="login_input"
          v-model="formData.username"
          autocomplete="username"
          :disabled="disabled || auth.busy"
          required
        />
      </label><br>
      <label class="login_label">
        Lösenord
        <input
          class="login_input"
          type="password"
          v-model="formData.password"
          autocomplete="current-password"
          :disabled="disabled || auth.busy"
          required
        />
      </label><br>
      <button class="login_btn" type="submit" :disabled="disabled || auth.busy">
        {{ auth.busy ? 'Loggar in…' : 'Logga in' }}
      </button>
      <p v-if="errorMessage" role="alert">{{ errorMessage }}</p>
    </form>
  </section>
</template>
