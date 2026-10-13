<script setup>
  import {reactive, ref} from 'vue';
  const formData = reactive({
    roleId: '',
    username: '',
    displayName: '',
    password: ''
  })

  const loading = ref(false);
  const errorMessage = ref('');
  const successMessage = ref('');
  
  async function handleRegister(){
    loading.value = true; 
    errorMessage.value = "";
    successMessage.value = "";
    try {
    const response = await fetch('http://localhost:3000/api/auth/register', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(formData),
    });

      const data = await response.json();

      if(!response.ok){
        throw new Error(data.Error || 'failed to register new user');
      }

      successMessage.value = "Registration successful!";
      formData.roleId = '';
      formData.username = '';
      formData.displayName = '';
      formData.password = '';
  } catch{
    errorMessage.value = err.errorMessage;
  } finally {
    loading.value = false;
  }
}
  
</script>

<template>
  <section class="register-container">
    <form @submit.prevent="handleRegister">
      <label for="role">Role: </label>
      <select id="role" v-model="formData.roleId" required>
        <option disabled value="">Please select a role</option>
        <option value="student">Student</option>
        <option value="teacher">Teacher</option>
        <option value="admin">Admin</option>
      </select>
      <label for="username">Username: </label><input type="text" id="username" v-model="formData.username" required>
      <label for="displayName">Displayname: </label><input type="text" id="displayName" v-model="formData.displayName" required>
      <label for="password">Password: </label><input id="password" v-model="formData.password" type="password" required />
      <button type="submit" :disabled="loading">
        {{ loading ? 'Registering...' : 'Sign Up' }}
      </button>

      <p v-if="errorMessage" class="error">{{ errorMessage }}</p>
      <p v-if="successMessage" class="success">{{ successMessage }}</p>
    </form>
  </section>
</template>
