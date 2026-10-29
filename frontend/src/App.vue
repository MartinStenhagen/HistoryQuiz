<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink, RouterView, useRouter } from 'vue-router'
import AchievementUnlockNotice from './components/AchievementUnlockNotice.vue'
import AnswerFeedback from './components/AnswerFeedback.vue'
import QuizQuestion from './components/QuizQuestion.vue'
import RegisterUser from './components/RegisterUser.vue'
import ResultScreen from './components/ResultScreen.vue'
import StartScreen from './components/StartScreen.vue'
import { useAchievementsStore } from './stores/achievements.js'
import { storeToRefs } from 'pinia'
import { useAuthStore } from './stores/auth'
import { api } from './api'
import LoginAuthorization from './components/loginAuthorization.vue'

const auth = useAuthStore()
const router = useRouter()
const authReady = computed(() => ['authenticated', 'anonymous'].includes(auth.status))

const { user: currentUser, isAuthenticated } = storeToRefs(auth)

onMounted(() => {
  auth.restore()
})

const pendingAnswer = ref(null)
const needsLogin = computed(
  () =>
    pendingAnswer.value?.accountId != null &&
    (!auth.isAuthenticated || pendingAnswer.value.accountId !== auth.user?.id),
)

async function submitAnswer(questionId, selectedOptionId) {
  if (!authReady.value || auth.busy) {
    throw new Error('Inloggningsstatus behöver kontrolleras först.')
  }

  if (!pendingAnswer.value) {
    pendingAnswer.value = {
      questionId,
      selectedOptionId,
      requestKey: crypto.randomUUID(),
      accountId: auth.user?.id ?? null,
    }
  }

  const attempt = pendingAnswer.value

  if (attempt.questionId !== questionId || attempt.selectedOptionId !== selectedOptionId) {
    throw new Error('Det tidigare försöket behöver skickas om med samma svar.')
  }

  if (attempt.accountId !== (auth.user?.id ?? null)) {
    throw new Error('Logga in på samma konto för att skicka om försöket.')
  }

  const startedAtVersion = auth.version
  const endpoint = attempt.accountId === null ? 'check' : 'answer'

  try {
    const result = await api(`/api/questions/${attempt.questionId}/${endpoint}`, {
      method: 'POST',
      accountId: attempt.accountId,
      body: {
        selectedOptionId: attempt.selectedOptionId,
        requestKey: attempt.requestKey,
      },
    })

    if (auth.version !== startedAtVersion) {
      throw new Error('Inloggningen ändrades under anropet.')
    }

    return result
  } catch (error) {
    if (
      (error.status === 401 || error.code === 'ACCOUNT_CHANGED') &&
      auth.version === startedAtVersion
    ) {
      auth.expire()
    }

    throw error
  }
}

const achievementsStore = useAchievementsStore()
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
const achievementNotices = ref([])
let nextNoticeId = 0

watch(() => auth.version, () => {
  achievementNotices.value = []
}, { flush: 'sync' })

function dismissAchievementNotice(noticeId) {
  achievementNotices.value = achievementNotices.value.filter(
    (notice) => notice.id !== noticeId
  )
}

const currentQuestion = computed(() => questions.value[questionIndex.value])

async function handleLogout() {
  if (loading.value || auth.busy) return
  errorMessage.value = ''
  try {
    await auth.logout()
    goHome()
  } catch {
    errorMessage.value = 'Kunde inte bekräfta utloggningen. Försök igen.'
    await auth.restore()
  }
}

function retryAnswer() {
  if (pendingAnswer.value) void chooseAnswer(pendingAnswer.value.selectedOptionId)
}

async function loadTopics() {
  if (topicsLoading.value) return

  topicsLoading.value = true
  topicsError.value = ''

  try {
    const data = await api('/api/topics')
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
  if (loading.value || auth.busy || !authReady.value) return

  errorMessage.value = ''
  screen.value = 'register'
}

function goHome() {
  // Byt inte spelomgång medan ett anrop pågår.
  if (loading.value || auth.busy) return

  screen.value = 'home'
  questions.value = []
  questionIndex.value = 0
  selectedAnswer.value = null
  pendingAnswer.value = null
  score.value = 0
  isCorrect.value = false
  errorMessage.value = ''
  achievementNotices.value = []
  void router.push('/')
}

async function startQuiz() {
  if (loading.value || topicsLoading.value || auth.busy || !authReady.value) return

  const selectedTopic = topics.value.find((topic) => topic.id === selectedTopicId.value)

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

    const data = await api(`/api/questions?${params}`)

    if (data.questions.length === 0) {
      errorMessage.value = 'Det finns inga spelbara frågor för det valda ämnet.'
      return
    }

    questions.value = data.questions.map((question) => ({
      id: question.id,
      question: question.questionText,
      answers: question.options,
    }))

    // Läs befintliga utmärkelser före första svaret så att gamla inte firas igen.
    if (auth.isAuthenticated) await achievementsStore.load()
    screen.value = 'quiz'
  } catch (error) {
    console.error(error)
    errorMessage.value = 'Kunde inte hämta frågorna. Försök igen.'
  } finally {
    loading.value = false
  }
}

async function chooseAnswer(optionId) {
  if (loading.value || selectedAnswer.value !== null || screen.value !== 'quiz') {
    return
  }

  const question = currentQuestion.value
  loading.value = true
  errorMessage.value = ''

  try {
    const result = await submitAnswer(question.id, optionId)

    // Hitta svarstexten som hör till rätt alternativ.
    question.correctAnswer =
      question.answers.find((option) => option.id === result.correctOptionId)?.text ?? ''

    question.explanation = result.explanation

    selectedAnswer.value = optionId
    isCorrect.value = result.isCorrect

    if (result.isCorrect) {
      score.value += 1
    }

    screen.value = 'feedback'
    if (result.saved) {
      const accountVersion = auth.version
      const newlyUnlocked = await achievementsStore.load()
      if (auth.version === accountVersion) {
        achievementNotices.value.push(
          ...newlyUnlocked.map((achievement) => ({
            id: nextNoticeId++,
            achievement,
          }))
        )
      }
    }
  } catch (error) {
    console.error(error)
    errorMessage.value =
      error.status === 401
        ? 'Sessionen har gått ut. Logga in igen för att spara samma svar.'
        : error.message || 'Kunde inte rätta svaret. Skicka om samma försök.'
  } finally {
    loading.value = false
  }
}

function nextStep() {
  if (loading.value || screen.value !== 'feedback') return

  selectedAnswer.value = null
  pendingAnswer.value = null
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
      <button
        class="brand"
        type="button"
        aria-label="Till startsidan"
        :disabled="loading"
        @click="goHome"
      >
        <span class="brand-mark" aria-hidden="true">H</span>
        <span>History <strong>Quiz</strong></span>
      </button>
      <nav class="top-navigation" aria-label="Huvudmeny">
        <RouterLink to="/" class="top-link">Quiz</RouterLink>
        <RouterLink to="/teacher/statistics" class="top-link" v-if="currentUser && currentUser.role === 'teacher'">Lärarvy</RouterLink>
        <RouterLink to="/achievements" class="top-link">Utmärkelser</RouterLink>
        <span class="age-badge"><span aria-hidden="true">✦</span> Historia för nyfikna</span>
      </nav>
    </header>
    <aside
      v-if="achievementNotices.length && $route.name === 'home' && ['quiz', 'feedback'].includes(screen)"
      class="achievement-notices"
      aria-label="Nya utmärkelser"
    >
      <AchievementUnlockNotice
        v-for="notice in achievementNotices"
        :key="notice.id"
        :achievement="notice.achievement"
        @dismiss="dismissAchievementNotice(notice.id)"
      />
    </aside>
    <main>
      <RouterView v-if="['teacher-statistics', 'achievements'].includes($route.name)" />
      <template v-else>
        <p v-if="auth.status === 'checking'" role="status">Kontrollerar inloggningen…</p>
        <div v-else-if="auth.status === 'error'" role="alert">
          <p>{{ auth.error }}</p>
          <button class="button button-secondary" :disabled="auth.busy" @click="auth.restore">
            Kontrollera igen
          </button>
        </div>
        <p v-if="$route.name !== 'achievements' && loading && screen !== 'register'" role="status">
          {{ screen === 'quiz' ? 'Rättar svaret…' : 'Hämtar frågor…' }}
        </p>

        <p v-if="$route.name !== 'achievements' && errorMessage" role="alert">
          {{ errorMessage }}
        </p>
        <template v-if="screen === 'home'">
          <p v-if="topicsLoading" role="status">Hämtar ämnen…</p>

          <div v-else-if="topicsError" role="alert">
            <p>{{ topicsError }}</p>
            <button class="button button-secondary" type="button" @click="loadTopics">
              Försök igen
            </button>
          </div>

          <p v-else-if="topics.length === 0">Det finns inga ämnen med spelbara frågor ännu.</p>

          <StartScreen
            v-if="screen === 'home'"
            :topics="topics"
            :selected-topic-id="selectedTopicId"
            :is-authenticated="isAuthenticated"
            :current-user="currentUser"
            @topic-change="selectedTopicId = $event"
            @start="startQuiz"
            @login-success="goHome"
            :account-busy="auth.busy"
            :disabled="loading || topicsLoading || !authReady || auth.busy"
            @register="showRegistration"
            @logout="handleLogout"
          />
        </template>
        <RegisterUser
          v-else-if="screen === 'register'"
          @busy-change="loading = $event"
          @home="goHome"
        />
        <template v-else-if="screen === 'quiz'">
          <QuizQuestion
            :question="currentQuestion"
            :question-number="questionIndex + 1"
            :total-questions="questions.length"
            :disabled="loading || !authReady || auth.busy || pendingAnswer !== null"
            @answer="chooseAnswer"
            @home="goHome"
          />
          <div v-if="pendingAnswer && !loading" class="answer-retry">
            <div v-show="needsLogin">
              <p>Logga in på samma konto för att fortsätta med det valda svaret.</p>
              <LoginAuthorization @login-success="retryAnswer" />
            </div>
            <button
              v-if="!needsLogin"
              class="button button-primary"
              :disabled="!authReady || auth.busy"
              @click="retryAnswer"
            >
              Försök igen med samma svar
            </button>
          </div>
        </template>
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
      </template>
    </main>
    <footer class="footer-note">
      <span aria-hidden="true">✦</span> Små frågor, stora upptäckter
      <span aria-hidden="true">✦</span>
    </footer>
  </div>
</template>

<style scoped>
.achievement-notices {
  position: fixed;
  z-index: 20;
  top: 96px;
  right: max(24px, calc((100vw - 1120px) / 2));
  display: grid;
  gap: 12px;
  pointer-events: none;
}

.achievement-notices > * { pointer-events: auto; }

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
  .achievement-notices {
    top: 78px;
    right: 12px;
    left: 12px;
    justify-items: center;
  }

  .top-navigation {
    gap: 2px;
  }
  .top-link {
    padding: 8px;
    font-size: 12px;
  }
  .age-badge {
    display: none;
  }
}
</style>
