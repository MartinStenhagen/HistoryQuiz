<script setup>
import { reactive, ref } from 'vue'
import { api } from '../api'

const emit = defineEmits(['registration-success'])

const formData = reactive({role: '', username: '', displayName: '', password: '' })
const loading = ref(false)
const errorMessage = ref('')
const successMessage = ref('')

async function handleRegister() {
  if (loading.value) return

  loading.value = true
  errorMessage.value = ''
  successMessage.value = ''

  try {
    await api('/api/register', {
      method: 'POST',
      body: { ...formData },
    })

    successMessage.value = 'Kontot är skapat!'
    emit('registration-success');
    formData.role = ''
    formData.username = ''
    formData.displayName = ''
    formData.password = ''
  } catch (error) {
    console.error(error)
    errorMessage.value = error.message || 'Kunde inte skapa kontot. Försök igen.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <section class="register-panel panel" aria-labelledby="register-title">
    <h1 id="register-title">Skapa konto</h1>
    <p class="intro">Du kan också spela quizet utan konto.</p>

    <form @submit.prevent="handleRegister">
      <fieldset :disabled="loading">
        <legend class="form-legend">Dina kontouppgifter</legend>
        <label for="register-role">Roll</label>
        <select id="register-role" v-model="formData.role" required>
            <option disabled value="">Välj en roll</option>
            <option value="1">Student</option>
            <option value="2">Lärare</option>
            <option value="3">Admin</option>
        </select>
        <label for="register-username">Användarnamn</label>
        <input
          id="register-username"
          v-model.trim="formData.username"
          autocomplete="username"
          maxlength="64"
          required
        />

        <label for="register-display-name">Visningsnamn</label>
        <input
          id="register-display-name"
          v-model.trim="formData.displayName"
          autocomplete="nickname"
          maxlength="100"
          required
        />

        <label for="register-password">Lösenord</label>
        <input
          id="register-password"
          v-model="formData.password"
          type="password"
          autocomplete="new-password"
          required
        />

        <button class="button button-primary" type="submit">
          {{ loading ? 'Skapar konto…' : 'Skapa konto' }}
        </button>
      </fieldset>

      <p v-if="errorMessage" role="alert">{{ errorMessage }}</p>
      <p v-if="successMessage" role="status">{{ successMessage }}</p>
    </form>
  </section>
</template>

<style scoped>
.register-panel {
  max-width: 580px;
  padding: 32px;
}

.register-panel h1 {
  margin-top: 16px;
}

fieldset {
  display: grid;
  gap: 12px;
  min-width: 0;
  margin: 0;
  padding: 0;
  border: 0;
}

.form-legend {
  padding: 0 0 16px;
  font-weight: bold;
}

input {
  width: 100%;
  min-width: 0;
  padding: 12px;
  border: 1px solid #999;
  border-radius: 8px;
  font: inherit;
}

input:focus-visible {
  outline: 3px solid #e5a33c;
  outline-offset: 3px;
}

fieldset:disabled,
.back-button:disabled {
  opacity: 0.6;
}

form p {
  margin-top: 20px;
}
</style>
