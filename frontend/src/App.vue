<script setup>
import { computed, onMounted, ref } from 'vue'
import { RouterLink, RouterView } from 'vue-router'
import AnswerFeedback from './components/AnswerFeedback.vue'
import QuizQuestion from './components/QuizQuestion.vue'
import RegisterUser from './components/RegisterUser.vue'
import ResultScreen from './components/ResultScreen.vue'
import StartScreen from './components/StartScreen.vue'

const screen = ref('home')
const questions = ref([])
const questionIndex = ref(0)
const selectedAnswer = ref(null)
const score = ref(0)
const isCorrect = ref(false)
const loading = ref(false)
const errorMessage = ref('')
const topics = ref([])
const selectedTopicId = ref(null)
const topicsLoading = ref(false)
const topicsError = ref('')

const currentQuestion = computed(
  () => questions.value[questionIndex.value]
)

// Gemensam hjälpfunktion för GET och POST.
async function requestJson(url, options) {
  const response = await fetch(url, options)
  const data = await response.json()

  if (!response.ok) {
    throw new Error(data.error || 'Anropet misslyckades.')
  }

  return data
}

const isAuthenticated = ref(false);
const currentUser = ref(null);


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
  screen.value = 'home';
};

const handleLogout = () => {
  localStorage.removeItem('user');
  currentUser.value = null;
  isAuthenticated.value = false;
};

async function loadTopics() {
  if (topicsLoading.value) return

  topicsLoading.value = true
  topicsError.value = ''

  try {
    const data = await requestJson('/api/topics')
    topics.value = data.topics

    // Behåll ett tidigare val bara om ämnet fortfarande finns.
    if (!topics.value.some((topic) => topic.id === selectedTopicId.value)) {
      selectedTopicId.value = null
    }
  } catch (error) {
    console.error(error)
    topicsError.value = 'Kunde inte hämta ämnen. Försök igen.'
  } finally {
    topicsLoading.value = false
  }
}

onMounted(loadTopics)

function showRegistration() {
  if (loading.value) return

  errorMessage.value = ''
  screen.value = 'register'
}

function goHome() {
  // Byt inte spelomgång medan ett anrop pågår.
  if (loading.value) return

  screen.value = 'home'
  questions.value = []
  questionIndex.value = 0
  selectedAnswer.value = null
  score.value = 0
  isCorrect.value = false
  errorMessage.value = ''
}

async function startQuiz() {
  if (loading.value || topicsLoading.value) return

  const selectedTopic = topics.value.find(
    (topic) => topic.id === selectedTopicId.value
  )

  if (!selectedTopic) {
    errorMessage.value = 'Välj ett ämne först.'
    return
  }

  goHome()
  loading.value = true

  try {
    const params = new URLSearchParams({
      topicId: String(selectedTopic.id),
      limit: '5',
    })

    const data = await requestJson(`/api/questions?${params}`)

    if (data.questions.length === 0) {
      errorMessage.value = 'Det finns inga spelbara frågor för det valda ämnet.'
      return
    }

    questions.value = data.questions.map((question) => ({
      id: question.id,
      question: question.questionText,
      answers: question.options,
    }))

    screen.value = 'quiz'
  } catch (error) {
    console.error(error)
    errorMessage.value = 'Kunde inte hämta frågorna. Försök igen.'
  } finally {
    loading.value = false
  }
}

async function chooseAnswer(optionId) {
  if (
    loading.value ||
    selectedAnswer.value !== null ||
    screen.value !== 'quiz'
  ) {
    return
  }

  const question = currentQuestion.value
  loading.value = true
  errorMessage.value = ''

  try {
    const result = await requestJson(
      `/api/questions/${question.id}/answer`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          selectedOptionId: optionId,
        }),
      }
    )

    // Hitta svarstexten som hör till rätt alternativ.
    question.correctAnswer = question.answers.find(
      (option) => option.id === result.correctOptionId
    )?.text ?? ''

    question.explanation = result.explanation

    selectedAnswer.value = optionId
    isCorrect.value = result.isCorrect

    if (result.isCorrect) {
      score.value += 1
    }

    screen.value = 'feedback'
  } catch (error) {
    console.error(error)
    errorMessage.value = 'Kunde inte rätta svaret. Välj ett alternativ igen.'
  } finally {
    loading.value = false
  }
}

function nextStep() {
  if (loading.value || screen.value !== 'feedback') return

  selectedAnswer.value = null
  isCorrect.value = false
  errorMessage.value = ''

  if (questionIndex.value >= questions.value.length - 1) {
    screen.value = 'result'
    return
  }

  questionIndex.value += 1
  screen.value = 'quiz'
}
</script>

<template>
  <div class="app-shell">
    <header class="topbar">
      <button class="brand" type="button" aria-label="Till startsidan" :disabled="loading" @click="goHome">
        <span class="brand-mark" aria-hidden="true">H</span>
        <span>History <strong>Quiz</strong></span>
      </button>
      <nav class="top-navigation" aria-label="Huvudmeny">
        <RouterLink to="/" class="top-link">Quiz</RouterLink>
        <RouterLink to="/achievements" class="top-link">Utmärkelser</RouterLink>
        <RouterLink to="/teachers" v-if="currentUser && currentUser.role === 'teacher'" class="top-link">Teacher view</RouterLink>
        <span class="age-badge"><span aria-hidden="true">✦</span> Historia för nyfikna</span>
      </nav>
    </header>
    <main>
      <p
        v-if="$route.name !== 'achievements' && loading && screen !== 'register'"
        role="status"
      >
        {{ screen === 'quiz' ? 'Rättar svaret…' : 'Hämtar frågor…' }}
      </p>

      <p
        v-if="$route.name !== 'achievements' && errorMessage"
        role="alert"
      >
        {{ errorMessage }}
      </p>
      <RouterView v-if="$route.matched.length > 0 && $route.name !== 'home'" />
      <template v-else-if="screen === 'home'">
        <p v-if="topicsLoading" role="status">
          Hämtar ämnen…
        </p>

        <div v-else-if="topicsError" role="alert">
          <p>{{ topicsError }}</p>
          <button
            class="button button-secondary"
            type="button"
            @click="loadTopics"
          >
            Försök igen
          </button>
        </div>

        <p v-else-if="topics.length === 0">
          Det finns inga ämnen med spelbara frågor ännu.
        </p>

        <StartScreen 
          v-if="screen === 'home'" 
          :topics="topics"
          :selected-topic-id="selectedTopicId"
          :is-authenticated="isAuthenticated"
          :current-user="currentUser"
          @topic-change="selectedTopicId = $event"
          @start="startQuiz" 
          @login-success="handleLoginSuccess"
          :disabled="loading || topicsLoading"
          @register="showRegistration"
          @logout="handleLogout"
        />
        
      </template>
      <RegisterUser
        v-else-if="screen === 'register'"
        @busy-change="loading = $event"
        @home="goHome"
      />
      <QuizQuestion
        v-else-if="screen === 'quiz'"
        :question="currentQuestion"
        :question-number="questionIndex + 1"
        :total-questions="questions.length"
        :disabled="loading"
        @answer="chooseAnswer"
        @home="goHome"
      />
      <AnswerFeedback
        v-else-if="screen === 'feedback'"
        :question="currentQuestion"
        :question-number="questionIndex + 1"
        :total-questions="questions.length"
        :is-correct="isCorrect"
        @next="nextStep"
        @home="goHome"
      />
      <ResultScreen
        v-else
        :score="score"
        :total-questions="questions.length"
        @restart="startQuiz"
        @home="goHome"
      />
    </main>
    <footer class="footer-note">
      <span aria-hidden="true">✦</span> Små frågor, stora upptäckter <span aria-hidden="true">✦</span>
    </footer>
  </div>
</template>

<style scoped>
.top-navigation {
  display: flex;
  align-items: center;
  gap: 10px;
}

.top-link {
  border-radius: 999px;
  padding: 9px 13px;
  color: #526078;
  font-size: 14px;
  font-weight: 700;
  text-decoration: none;
}

.top-link:hover,
.top-link.router-link-exact-active {
  background: #f1e9d9;
  color: #9b5c3f;
}

@media (max-width: 700px) {
  .top-navigation { gap: 2px; }
  .top-link { padding: 8px; font-size: 12px; }
  .age-badge { display: none; }
}
</style>
