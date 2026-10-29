<script setup>
import { computed,ref, onMounted } from 'vue'
import teacherUserRegistration from '@/components/teacherUserRegistration.vue'

const isFormVisible = ref(false);
function accuracyClass(value) {
  if (value >= 80) return 'accuracy-high'
  if (value >= 65) return 'accuracy-medium'
  return 'accuracy-low'
}

const students = ref([]);
const totalAnswers = computed(() => {
  return students.value.reduce((sum, student) => sum + Number(student.total_answers || 0), 0);
}); 

const totalCorrect = computed(() => {
  return students.value.reduce((sum, student) => sum + Number(student.total_correct || 0), 0);
})

const totalCorrectPercent = computed(() => {
  const totals = students.value.reduce(
    (acc, student) => {
      acc.correct += Number(student.total_correct || 0);
      acc.wrong += Number(student.total_wrong || 0);
      return acc;
    },
    { correct: 0, wrong: 0 }
  );

  const totalAnswers = totals.correct + totals.wrong;
  if (totalAnswers === 0) return 0;

  return Number(((totals.correct / totalAnswers) * 100).toFixed(1));
});

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


    onMounted(() => {
        getStudents();
    });
</script>

<template>
  <section class="teacher-dashboard" aria-labelledby="teacher-title">
    <header class="dashboard-heading">
      <div>
        <p class="dashboard-eyebrow"><span aria-hidden="true">✦</span> Läraröversikt</p>
        <h1 id="teacher-title">Elevernas framsteg</h1>
        <p class="dashboard-intro">En snabb överblick över hur det går med historiefrågorna.</p>
      </div>
      <span class="demo-label"><span aria-hidden="true">●</span>Elevestatistik</span>
    </header>

    <div class="summary-grid" aria-label="Sammanfattning">
      <article class="summary-card students-card">
        <span class="summary-icon" aria-hidden="true">👩‍🎓</span>
        <div><p>Elever</p><strong>{{ students.length }}</strong></div>
      </article>
      <article class="summary-card answers-card">
        <span class="summary-icon" aria-hidden="true">📝</span>
        <div><p>Besvarade frågor</p><strong>{{ totalAnswers }}</strong></div>
      </article>
      <article class="summary-card accuracy-card">
        <span class="summary-icon" aria-hidden="true">🌟</span>
        <div><p>Rätt svar totalt</p><strong>{{ totalCorrect }} <small>{{ totalCorrectPercent }}(%)</small></strong></div>
      </article>
    </div>

    <section class="students-panel" aria-labelledby="students-title">
      <div class="table-heading">
        <div>
          <h2 id="students-title">Resultat per elev</h2>
          <p>Andel rätt visas med både färg och procent.</p>
        </div>
        <span class="student-count">{{ students.length }} elever</span>
      </div>

      <div class="table-scroll">
        <table>
          <thead>
            <tr>
              <th scope="col">Elev</th>
              <th scope="col">Besvarade</th>
              <th scope="col">Rätt</th>
              <th scope="col">Fel</th>
              <th scope="col">Andel rätt</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="student in students" :key="student.id">
              <th scope="row" class="student-name">
                <span class="student-avatar" aria-hidden="true">{{ student.username.charAt(0) }}</span>
                {{ student.username }}
              </th>
              <td>{{ student.total_answers }}</td>
              <td class="number-correct">{{ student.total_correct }}</td>
              <td class="number-wrong">{{ student.total_wrong }}</td>
              <td>
                <div class="accuracy-cell">
                  <div
                    class="accuracy-track"
                    role="progressbar"
                    :aria-label="`Andel rätt för ${student.name}`"
                    :aria-valuenow="student.accuracy_percent"
                    aria-valuemin="0"
                    aria-valuemax="100"
                  >
                    <span :class="accuracyClass(student.accuracy_percent)" :style="{ width: `${student.accuracy_percent}%` }"></span>
                  </div>
                  <strong>{{ student.accuracy_percent }}%</strong>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
    <section class="showRegistrationForm">
        <h3 class="formButton" @click="isFormVisible = !isFormVisible">{{ isFormVisible ? 'Stäng' : 'Lägg till konto' }}</h3>
        <teacherUserRegistration v-if="isFormVisible" />
      </section>
  </section>
</template>

<style scoped>
.teacher-dashboard {
  width: min(100%, 1000px);
  align-self: start;
  padding: 8px 0 22px;
}

.showRegistrationForm{
  margin-top: 10px;
}

.formButton{
  border-radius: 999px;
  padding: 9px 13px;
  color: #526078;
  border-color: #c86b49;
  font-size: 14px;
  font-weight: 700;
  text-decoration: none;
}

.dashboard-heading,
.table-heading {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
}

.dashboard-heading { margin-bottom: 23px; }
.dashboard-eyebrow { margin: 0 0 9px; color: #c86b49; font-size: 13px; font-weight: 800; letter-spacing: 0.06em; text-transform: uppercase; }
.dashboard-eyebrow span { color: #e8aa3d; }
.dashboard-heading h1 { margin: 0; color: #25324b; font-size: clamp(30px, 4vw, 42px); line-height: 1.15; }
.dashboard-intro { margin: 9px 0 0; color: #687188; font-size: 16px; line-height: 1.5; }
.demo-label { flex: 0 0 auto; border: 1px solid #efdfbd; border-radius: 99px; padding: 9px 13px; background: #fff8e8; color: #8a682d; font-size: 13px; font-weight: 800; }
.demo-label span { color: #e8aa3d; font-size: 10px; }

.summary-grid { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 15px; margin-bottom: 19px; }
.summary-card { display: flex; align-items: center; gap: 14px; min-height: 110px; border: 1px solid #eae3d6; border-radius: 19px; padding: 18px 20px; background: rgba(255, 255, 255, 0.88); box-shadow: 0 4px 0 rgba(87, 77, 55, 0.04); }
.summary-icon { width: 49px; height: 49px; flex: 0 0 49px; display: grid; place-items: center; border-radius: 16px; font-size: 25px; }
.students-card .summary-icon { background: #eaf1ff; }
.answers-card .summary-icon { background: #fff1dc; }
.accuracy-card .summary-icon { background: #e8f5e9; }
.summary-card p { margin: 0 0 4px; color: #70798b; font-size: 14px; }
.summary-card strong { color: #2f3c55; font-size: 27px; line-height: 1.1; }
.summary-card strong small { color: #51805d; font-size: 15px; }

.students-panel { overflow: hidden; border: 1px solid #e9e2d5; border-radius: 21px; background: rgba(255, 255, 255, 0.94); box-shadow: 0 8px 24px rgba(64, 57, 43, 0.05); }
.table-heading { padding: 20px 23px 17px; }
.table-heading h2 { margin: 0; color: #303d55; font-size: 20px; }
.table-heading p { margin: 5px 0 0; color: #7a8292; font-size: 13px; }
.student-count { border-radius: 99px; padding: 7px 11px; background: #f1f4f7; color: #59677c; font-size: 12px; font-weight: 800; white-space: nowrap; }
.table-scroll { overflow-x: auto; }
table { width: 100%; border-collapse: collapse; text-align: left; }
thead { background: #f7f5f0; }
th, td { padding: 13px 18px; border-bottom: 1px solid #f0ede7; color: #566177; font-size: 14px; white-space: nowrap; }
thead th { color: #778093; font-size: 12px; font-weight: 800; }
tbody tr:last-child th, tbody tr:last-child td { border-bottom: 0; }
tbody tr:hover { background: #fffdf8; }
.student-name { display: flex; align-items: center; gap: 10px; color: #34415a; font-weight: 800; }
.student-avatar { width: 31px; height: 31px; display: inline-grid; place-items: center; border-radius: 11px; background: #edf0fb; color: #566a9a; font-size: 13px; }
tbody tr:nth-child(even) .student-avatar { background: #f9eddf; color: #9c6b3d; }
.number-correct { color: #388052; font-weight: 800; }
.number-wrong { color: #a66f53; }
.accuracy-cell { display: flex; align-items: center; gap: 10px; }
.accuracy-track { width: 100px; height: 9px; overflow: hidden; border-radius: 99px; background: #eeede8; }
.accuracy-track span { height: 100%; display: block; border-radius: inherit; }
.accuracy-high { background: #65ad78; }
.accuracy-medium { background: #e6ad49; }
.accuracy-low { background: #dd8761; }
.accuracy-cell strong { min-width: 38px; color: #3e4a61; font-size: 13px; }
.table-note { margin: 0; border-top: 1px solid #f0ede7; padding: 12px 19px; color: #7a8292; font-size: 12px; }

@media (max-width: 700px) {
  .dashboard-heading { align-items: flex-start; flex-direction: column; gap: 13px; }
  .summary-grid { grid-template-columns: 1fr; gap: 10px; }
  .summary-card { min-height: 82px; padding: 13px 16px; }
  .summary-icon { width: 43px; height: 43px; flex-basis: 43px; }
  .table-heading { padding: 17px 16px 13px; }
  th, td { padding: 12px 13px; }
}
</style>
