<script setup>
import { ref, onMounted } from 'vue';

    const students = ref([]);
    const selectedStudent = ref(null);
    const errorMessage = ref('');
    
    async function getStudents() {
        try {
            const response = await fetch('/api/getstudents');
            const data = await response.json();
        
            if (!response.ok) throw new Error(data.error);

            students.value = data;
            } catch (err) {
                errorMessage.value = err.message;
            }
    }

    async function selectStudent(userId) {
        errorMessage.value = '';
        try {
            const response = await fetch(`/api/students/${userId}/results`);
            const data = await response.json();
            if (!response.ok) throw new Error(data.error);
            selectedStudent.value = data;
        } catch (err) {
            console.error("Server returned non-JSON:", text)
            errorMessage.value = err.message;
        }
}

    onMounted(() => {
        getStudents();
    });
</script>

<template>
    <section>
        <p v-if="errorMessage" class="error">{{ errorMessage }}</p>
        <table>
            <thead>
                <tr>
                    <th>Username</th>
                    <th>Display name</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="student in students" :key="student.username">
                    <td><a href="#" @click.prevent="selectStudent(student.id)">
                            {{ student.username }}
                        </a></td>
                    <td>{{ student.display_name }}</td>
                </tr>
            </tbody>
        </table>

        <section v-if="selectedStudent">
            <h3>Statistik för: {{ selectedStudent.username }}</h3>
            <p>Totalt svarade: {{ selectedStudent.total_answers }}</p>
            <p>Rätt: {{ selectedStudent.total_correct }}</p>
            <p>Fel: {{ selectedStudent.total_wrong }}</p>
        </section>
    </section>
</template>