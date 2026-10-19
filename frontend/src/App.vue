<script setup>
import { onMounted, computed, ref } from 'vue'
import AnswerFeedback from './components/AnswerFeedback.vue'
import QuizQuestion from './components/QuizQuestion.vue'
import ResultScreen from './components/ResultScreen.vue'
import StartScreen from './components/StartScreen.vue'
import { demoQuestions } from './data/demoQuestions'
import loginAuthorization from './components/loginAuthorization.vue'

const screen = ref('home')
const questionIndex = ref(0)
const selectedAnswer = ref('')
const score = ref(0)
const currentQuestion = computed(() => demoQuestions[questionIndex.value])
const isCorrect = computed(() => selectedAnswer.value === currentQuestion.value.correctAnswer)

const isAuthenticated = ref(false);
const currentUser = ref(null);
const showLoginPopup = ref(false);

onMounted(() => {
  const savedUser = localStorage.getItem('user');
  if(savedUser){
    currentUser.value = JSON.parse(savedUser);
    isAuthenticated.value = true;
  }
});

const handleLoginSuccess = (userData) => {
  currentUser.value = userData;
  isAuthenticated.value = true;
  showLoginPopup.value = false;
  screen.value = 'home';
}

const handleLogout = () => {
  localStorage.removeItem('user');
  currentUser.value = null;
  isAuthenticated.value = false;
  screen.value = 'home';
}

function goHome() {
  screen.value = 'home'
  questionIndex.value = 0
  selectedAnswer.value = ''
  score.value = 0
}

function startQuiz() {
  questionIndex.value = 0
  selectedAnswer.value = ''
  score.value = 0
  screen.value = 'quiz'
}

function chooseAnswer(answer) {
  if (selectedAnswer.value) return
  selectedAnswer.value = answer
  if (answer === currentQuestion.value.correctAnswer) score.value += 1
  screen.value = 'feedback'
}

function nextStep() {
  if (questionIndex.value === demoQuestions.length - 1) {
    screen.value = 'result'
    return
  }
  questionIndex.value += 1
  selectedAnswer.value = ''
  screen.value = 'quiz'
}
</script>

<template>
  <div class="app-shell">
    <header class="topbar">
      <button class="brand" type="button" aria-label="Till startsidan" @click="goHome">
        <span class="brand-mark" aria-hidden="true">H</span>
        <span>History <strong>Quiz</strong></span>
      </button>
      <span class="age-badge"><span aria-hidden="true">✦</span> Historia för nyfikna</span>
      <section class="login_container">
        <span v-if="isAuthenticated" style="margin-right: 15px; color: #687188;">Logged in as: {{ currentUser.displayName }}</span>
        <button class="login_btn" v-if="isAuthenticated" @click="handleLogout">Log out</button>
        <button v-else class="login_btn" @click="showLoginPopup = !showLoginPopup" >Log in</button>
        <section v-if="showLoginPopup && !isAuthenticated" class="login-popup">
          <loginAuthorization @login-success="handleLoginSuccess" />
        </section>
      </section>
      
    </header>
    <main>
        <StartScreen v-if="screen === 'home'" @start="startQuiz" />
        <QuizQuestion
          v-else-if="screen === 'quiz'"
          :question="currentQuestion"
          :question-number="questionIndex + 1"
          :total-questions="demoQuestions.length"
          @answer="chooseAnswer"
          @home="goHome"
          />
      <AnswerFeedback
        v-else-if="screen === 'feedback'"
        :question="currentQuestion"
        :question-number="questionIndex + 1"
        :total-questions="demoQuestions.length"
        :is-correct="isCorrect"
        @next="nextStep"
        @home="goHome"
      />
      <ResultScreen
        v-else
        :score="score"
        :total-questions="demoQuestions.length"
        @restart="startQuiz"
        @home="goHome"
      />
    </main>
    <footer class="footer-note">
      <span aria-hidden="true">✦</span> Små frågor, stora upptäckter <span aria-hidden="true">✦</span>
    </footer>
  </div>
</template>
