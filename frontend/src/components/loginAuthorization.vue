<script setup>
    import {reactive, ref} from "vue";
    const formData = reactive({
        username: '',
        password: ''
    });

    const errorMessage = ref('');
    const succesMessage = ref('');
    const emit = defineEmits(['login-success']);
    let currentUser = ref(null);
    let userRole = ref(null);

    async function handleLogin() {
        errorMessage.value = '';
        try{
            const response = await fetch('/api/login', {
                method: 'POST',
                headers: {'Content-type': 'application/json'},
                body: JSON.stringify(formData),
            });

            const data = await response.json();

            if(!response.ok){
                throw new Error(data.Error || 'failed to login user');
            }

            succesMessage.value = 'Login Succesful'
            formData.username = '';
            formData.password = '';

            console.log(data);
            if (data.user.role_id === 1){
                userRole.value = 'student';
            } else if(data.user.role_id === 2){
                userRole.value = 'teacher';
            } else if(data.user.role_id === 3){
                userRole.value = 'admin';
            } else{
                throw new error('not a valid role');
            }

            currentUser.value = {
                role: userRole,
                userName: data.user.username,
                displayName: data.user.display_name
            }

            localStorage.setItem('user', JSON.stringify(currentUser.value));
            emit('login-success', currentUser.value);
        }catch(err){
            errorMessage.value = err.message;
        }
    }
</script>

<template>
    <section class="login-container">
        <form @submit.prevent="handleLogin">
            <label class="login_label" for="username">Username: </label>
            <input class="login_input" type="text" v-model="formData.username" required> <br>
            <label class="login_label" for="password">Password: </label>
            <input class="login_input" type="password" v-model="formData.password" required><br>
            <button class="login_btn" type="submit">Log in</button>
            <p v-if="errorMessage" style="color: red;">{{ errorMessage }}</p>
            <p v-if="succesMessage" style="color: green;">{{ succesMessage }}</p>
        </form>
    </section>
</template>