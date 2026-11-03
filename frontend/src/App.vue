<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink, RouterView, useRouter } from 'vue-router'
import AchievementUnlockNotice from './components/AchievementUnlockNotice.vue'
import LevelUnlockNotice from './components/LevelUnlockNotice.vue'
import AnswerFeedback from './components/AnswerFeedback.vue'
import CaesarCharacter from './components/CaesarCharacter.vue'
import QuizQuestion from './components/QuizQuestion.vue'
import RegisterUser from './components/RegisterUser.vue'
import ResultScreen from './components/ResultScreen.vue'
import StartScreen from './components/StartScreen.vue'
import { useAchievementsStore } from './stores/achievements.js'
import { useDifficultyProgressStore } from './stores/difficultyProgress.js'
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
const pendingChallengeStart = ref(null)
const gameMode = ref('regular')
const challengeRun = ref(null)
const isChallenge = computed(() => gameMode.value === 'challenge')
const requiredAccountId = computed(() =>
  pendingAnswer.value?.accountId ??
  pendingChallengeStart.value?.accountId ??
  (isChallenge.value ? challengeRun.value?.accountId : null)
)
const needsLogin = computed(
  () =>
    requiredAccountId.value != null &&
    (!auth.isAuthenticated || requiredAccountId.value !== auth.user?.id),
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
      accountId: isChallenge.value ? challengeRun.value.accountId : auth.user?.id ?? null,
      runId: isChallenge.value ? challengeRun.value.runId : null,
    }
  }

  const attempt = pendingAnswer.value

  if (
    attempt.questionId !== questionId ||
    attempt.selectedOptionId !== selectedOptionId ||
    attempt.runId !== (isChallenge.value ? challengeRun.value.runId : null)
  ) {
    throw new Error('Det tidigare försöket behöver skickas om med samma svar.')
  }

  if (attempt.accountId !== (auth.user?.id ?? null)) {
    throw new Error('Logga in på samma konto för att skicka om försöket.')
  }

  const startedAtVersion = auth.version
  const endpoint = attempt.runId === null
    ? `/api/questions/${attempt.questionId}/${attempt.accountId === null ? 'check' : 'answer'}`
    : `/api/challenges/runs/${attempt.runId}/answers`

  try {
    // En ny inloggning nollställer utmärkelsernas baslinje, även mitt i en omgång.
    if (attempt.runId !== null && achievementsStore.statistics === null) {
      await prepareAchievementBaseline(startedAtVersion)
    }
    const result = await api(endpoint, {
      method: 'POST',
      accountId: attempt.accountId,
      body: {
        ...(attempt.runId !== null ? { questionId: attempt.questionId } : {}),
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
const difficultyProgressStore = useDifficultyProgressStore()
const screen = ref('home')
const questions = ref([])
const questionIndex = ref(0)
const selectedAnswer = ref(null)
const score = ref(0)
const isCorrect = ref(false)
const caesarReaction = computed(() => {
  if (!isChallenge.value) return 'idle'
  if (screen.value === 'feedback') return isCorrect.value ? 'correct' : 'incorrect'
  if (screen.value === 'result') {
    return challengeRun.value?.status === 'passed' ? 'correct' : 'incorrect'
  }
  return 'idle'
})
const loading = ref(false)
const loadingMessage = ref('')
const errorMessage = ref('')
const topics = ref([])
const selectedTopicId = ref(null)
const topicsLoading = ref(false)
const topicsError = ref('')
const achievementNotices = ref([])
const selectedDifficulty = ref(1)
const levelUnlockNotice = ref(null)
const challengeStatus = ref(null)
const challengeStatusLoading = ref(false)
const challengeStatusError = ref('')
let nextNoticeId = 0
let challengeStatusRequest = 0

watch(() => auth.version, () => {
  achievementNotices.value = []
  challengeStatus.value = null
  challengeStatusError.value = ''
  challengeStatusLoading.value = false
  challengeStatusRequest += 1
  if (auth.isAuthenticated) void loadChallengeStatus()
}, { flush: 'sync' })

const canShowChallengeOffer = computed(() =>
  auth.isAuthenticated &&
  (screen.value === 'home' || (screen.value === 'result' && !isChallenge.value)) &&
  challengeStatus.value?.challenge.isActive &&
  challengeStatus.value.challenge.topicId === selectedTopicId.value &&
  (challengeStatus.value.available ||
    selectedDifficulty.value === challengeStatus.value.challenge.requiredDifficulty)
)

async function loadChallengeStatus() {
  if (!auth.isAuthenticated) return

  const request = ++challengeStatusRequest
  const accountVersion = auth.version
  const accountId = auth.user.id
  const isCurrent = () => request === challengeStatusRequest && auth.version === accountVersion
  challengeStatusLoading.value = true
  challengeStatusError.value = ''

  try {
    const data = await api('/api/challenges/caesar/status', { accountId })
    if (!isCurrent()) return
    if (data.userId !== accountId) {
      auth.expire()
      return
    }
    challengeStatus.value = data
  } catch (error) {
    if (!isCurrent()) return
    challengeStatus.value = null
    if (error.status === 401 || error.code === 'ACCOUNT_CHANGED') {
      auth.expire()
    } else if (error.status !== 404) {
      challengeStatusError.value = 'Kunde inte kontrollera utmaningen. Försök igen.'
    }
  } finally {
    if (isCurrent()) challengeStatusLoading.value = false
  }
}

const unlockedDifficulties = computed(() =>
  difficultyProgressStore.unlockedLevels(selectedTopicId.value)
)

function dismissAchievementNotice(noticeId) {
  achievementNotices.value = achievementNotices.value.filter(
    (notice) => notice.id !== noticeId
  )
}

async function refreshAchievementNotices(accountVersion) {
  if (!auth.isAuthenticated || auth.version !== accountVersion) return

  const newlyUnlocked = await achievementsStore.load()

  if (auth.version !== accountVersion) return

  const queuedCodes = new Set(
    achievementNotices.value.map(notice => notice.achievement.code)
  )

  for (const achievement of newlyUnlocked) {
    if (queuedCodes.has(achievement.code)) continue

    achievementNotices.value.push({
      id: nextNoticeId++,
      achievement,
    })

    queuedCodes.add(achievement.code)
  }
}

async function prepareAchievementBaseline(accountVersion) {
  await achievementsStore.load()
  if (auth.version !== accountVersion || !auth.isAuthenticated) {
    throw new Error('Inloggningen ändrades. Logga in på samma konto och försök igen.')
  }
  if (achievementsStore.error || achievementsStore.loading || achievementsStore.statistics === null) {
    throw new Error('Kunde inte hämta dina utmärkelser. Försök igen.')
  }
}

async function startChallenge() {
  if (loading.value || auth.busy || !authReady.value) return
  if (!auth.isAuthenticated || needsLogin.value) {
    errorMessage.value = 'Logga in på samma konto för att starta utmaningen.'
    return
  }
  if (!pendingChallengeStart.value && !challengeStatus.value?.available) {
    errorMessage.value = 'Utmaningen är inte tillgänglig ännu.'
    return
  }

  pendingChallengeStart.value ??= {
    accountId: auth.user.id,
    requestKey: crypto.randomUUID(),
  }
  const attempt = pendingChallengeStart.value
  const accountVersion = auth.version
  loading.value = true
  loadingMessage.value = 'Startar utmaningen…'
  errorMessage.value = ''

  try {
    await prepareAchievementBaseline(accountVersion)
    const run = await api('/api/challenges/caesar/runs', {
      method: 'POST',
      accountId: attempt.accountId,
      body: { requestKey: attempt.requestKey },
    })
    if (auth.version !== accountVersion) {
      throw new Error('Inloggningen ändrades under anropet.')
    }

    const nextIndex = run.questions.findIndex(question => question.id === run.nextQuestionId)
    if (run.status === 'in_progress' && nextIndex < 0) {
      throw new Error('Kunde inte hitta nästa utmaningsfråga. Försök starta igen.')
    }
    questions.value = run.questions.map(question => ({
      id: question.id,
      question: question.questionText,
      answers: question.options,
    }))
    challengeRun.value = { ...run, accountId: attempt.accountId }
    gameMode.value = 'challenge'
    questionIndex.value = Math.max(0, nextIndex)
    score.value = run.correctCount
    selectedAnswer.value = null
    pendingAnswer.value = null
    isCorrect.value = false
    levelUnlockNotice.value = null
    pendingChallengeStart.value = null
    screen.value = run.status === 'in_progress' ? 'quiz' : 'result'
  } catch (error) {
    if (
      (error.status === 401 || error.code === 'ACCOUNT_CHANGED') &&
      auth.version === accountVersion
    ) {
      auth.expire()
    }
    errorMessage.value = error.message || 'Kunde inte starta utmaningen. Försök igen.'
  } finally {
    loading.value = false
  }
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

function resumePendingAction() {
  if (pendingAnswer.value) retryAnswer()
  else if (pendingChallengeStart.value) void startChallenge()
}

function restartQuiz() {
  if (isChallenge.value) void startChallenge()
  else void startQuiz()
}

function dismissLevelUnlockNotice() {
  levelUnlockNotice.value = null
}

function changeTopic(topicId) {
  selectedTopicId.value = topicId
  const levelsForTopic = difficultyProgressStore.unlockedLevels(topicId)
  selectedDifficulty.value = Math.max(...levelsForTopic)
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
  pendingChallengeStart.value = null
  gameMode.value = 'regular'
  challengeRun.value = null
  score.value = 0
  isCorrect.value = false
  errorMessage.value = ''
  achievementNotices.value = []
  void router.push('/')
  levelUnlockNotice.value = null
  if (auth.isAuthenticated) void loadChallengeStatus()
}

async function startQuiz() {
  if (loading.value || topicsLoading.value || auth.busy || !authReady.value) return

  const selectedTopic = topics.value.find((topic) => topic.id === selectedTopicId.value)

  if (!selectedTopic) {
    errorMessage.value = 'Välj ett ämne först.'
    return
  }

  if (!difficultyProgressStore.isUnlocked(selectedTopic.id, selectedDifficulty.value)) {
    errorMessage.value = 'Den här nivån är låst. Klara föregående nivå först.'
    return
  }

  goHome()
  loading.value = true
  loadingMessage.value = 'Hämtar frågor…'
  const accountVersion = auth.version

  try {
    const params = new URLSearchParams({
      topicId: String(selectedTopic.id),
      difficulty: String(selectedDifficulty.value),
      limit: '5',
    })

    const data = await api(`/api/questions?${params}`)

    if (data.questions.length === 0) {
      errorMessage.value = `Det finns inga spelbara frågor på nivå ${selectedDifficulty.value} i den valda kategorin ännu.`
      return
    }

    questions.value = data.questions.map((question) => ({
      id: question.id,
      question: question.questionText,
      answers: question.options,
    }))

    // Läs befintliga utmärkelser före första svaret så att gamla inte firas igen.
    if (auth.isAuthenticated) await achievementsStore.load()
    if (auth.version !== accountVersion) {
      throw new Error('Inloggningen ändrades under anropet.')
    }
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
    loading.value || auth.busy || !authReady.value || needsLogin.value ||
    selectedAnswer.value !== null || screen.value !== 'quiz'
  ) {
    return
  }

  const question = currentQuestion.value
  loading.value = true
  loadingMessage.value = 'Rättar svaret…'
  errorMessage.value = ''
  const accountVersion = auth.version

  try {
    const result = await submitAnswer(question.id, optionId)

    // Hitta svarstexten som hör till rätt alternativ.
    question.correctAnswer =
      question.answers.find((option) => option.id === result.correctOptionId)?.text ?? ''

    question.explanation = result.explanation

    selectedAnswer.value = optionId
    isCorrect.value = result.isCorrect

    if (isChallenge.value) {
      challengeRun.value = { ...challengeRun.value, ...result.run }
      score.value = result.run.correctCount
    } else if (result.isCorrect) {
      score.value += 1
    }

    const isLastQuestion = questionIndex.value === questions.value.length - 1

    if (!isChallenge.value && isLastQuestion && score.value === questions.value.length) {
      const unlockedDifficulty = difficultyProgressStore.unlockNextLevel(
        selectedTopicId.value,
        selectedDifficulty.value
      )

      if (unlockedDifficulty) {
        const selectedTopic = topics.value.find(
          (topic) => topic.id === selectedTopicId.value
        )
        levelUnlockNotice.value = {
          categoryName: selectedTopic?.name ?? 'kategorin',
          difficulty: unlockedDifficulty,
        }
      }
    }

    screen.value = 'feedback'
    if (result.saved) {
      loadingMessage.value = 'Uppdaterar framsteg…'
      await refreshAchievementNotices(accountVersion)
      if (!isChallenge.value && selectedDifficulty.value === 3 && isLastQuestion) {
        await loadChallengeStatus()
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

  if (isChallenge.value) {
    if (challengeRun.value.status !== 'in_progress') {
      screen.value = 'result'
      return
    }
    const nextIndex = questions.value.findIndex(
      question => question.id === challengeRun.value.nextQuestionId
    )
    if (nextIndex < 0) {
      errorMessage.value = 'Nästa fråga kunde inte hittas. Gå till startsidan och försök igen.'
      return
    }
    questionIndex.value = nextIndex
    screen.value = 'quiz'
    return
  }

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
      v-if="achievementNotices.length && $route.name === 'home' && ['quiz', 'feedback', 'result'].includes(screen)"
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
    <aside
      v-if="levelUnlockNotice && $route.name === 'home' && screen === 'feedback'"
      class="level-unlock-notice"
      aria-label="Ny nivå upplåst"
    >
      <LevelUnlockNotice
        :category-name="levelUnlockNotice.categoryName"
        :difficulty="levelUnlockNotice.difficulty"
        @dismiss="dismissLevelUnlockNotice"
      />
    </aside>
    <main :class="{ 'challenge-active': isChallenge && $route.name === 'home' }">
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
          {{ loadingMessage }}
        </p>

        <p v-if="$route.name !== 'achievements' && errorMessage" role="alert">
          {{ errorMessage }}
        </p>
        <!-- Behåll formuläret tills login-success har hunnit skickas efter inloggningen. -->
        <div v-if="requiredAccountId != null && !loading" v-show="needsLogin" class="answer-retry">
          <p>Logga in på samma konto för att fortsätta med ditt försök.</p>
          <LoginAuthorization @login-success="resumePendingAction" />
        </div>
        <div
          v-if="achievementsStore.error && ['feedback', 'result'].includes(screen)"
          class="achievement-retry"
          role="alert"
        >
          <p>Svaret är sparat, men utmärkelserna kunde inte hämtas.</p>
          <button
            class="button button-secondary"
            type="button"
            :disabled="loading || achievementsStore.loading || !auth.isAuthenticated"
            @click="refreshAchievementNotices(auth.version)"
          >
            Hämta utmärkelser igen
          </button>
        </div>
        <p
          v-if="isChallenge && ['quiz', 'feedback', 'result'].includes(screen)"
          class="challenge-context"
        >
          <span aria-hidden="true">🏛️</span>
          Utmaning med {{ challengeRun.characterName }} ·
          Mål: {{ challengeRun.correctToPass }} av {{ challengeRun.questionCount }} rätt
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
            :selected-difficulty="selectedDifficulty"
            :unlocked-difficulties="unlockedDifficulties"
            :is-authenticated="isAuthenticated"
            :current-user="currentUser"
            @topic-change="changeTopic"
            @difficulty-change="selectedDifficulty = $event"
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
        <div
          v-else-if="['quiz', 'feedback', 'result'].includes(screen)"
          class="game-layout"
          :class="{ 'has-character': isChallenge && challengeRun?.characterKey === 'caesar' }"
        >
          <CaesarCharacter
            v-if="isChallenge && challengeRun?.characterKey === 'caesar'"
            :state="caesarReaction"
            :reaction-key="`${challengeRun.runId}:${screen}:${currentQuestion?.id ?? ''}`"
          />
          <div class="game-content">
            <template v-if="screen === 'quiz'">
              <QuizQuestion
                :question="currentQuestion"
                :question-number="questionIndex + 1"
                :total-questions="questions.length"
                :disabled="loading || !authReady || auth.busy || needsLogin || pendingAnswer !== null"
                @answer="chooseAnswer"
                @home="goHome"
              />
              <div v-if="pendingAnswer && !loading && !needsLogin" class="answer-retry">
                <button
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
              :disabled="loading || auth.busy"
              @next="nextStep"
              @home="goHome"
            />
            <ResultScreen
              v-else-if="screen === 'result'"
              :score="score"
              :total-questions="questions.length"
              :challenge="isChallenge ? challengeRun : null"
              :disabled="loading || auth.busy || (isChallenge && needsLogin)"
              @restart="restartQuiz"
              @home="goHome"
            />
          </div>
        </div>
        <section
          v-if="canShowChallengeOffer"
          class="challenge-offer panel"
          aria-labelledby="challenge-offer-title"
        >
          <p class="eyebrow"><span aria-hidden="true">🏛️</span> Historisk utmaning</p>
          <h2 id="challenge-offer-title">
            {{ challengeStatus.available
              ? `${challengeStatus.challenge.characterName} utmanar dig!`
              : `Möt ${challengeStatus.challenge.characterName}` }}
          </h2>
          <p v-if="challengeStatus.available">
            Du är redo! Svara rätt på minst
            {{ challengeStatus.challenge.requiredCorrectToWin }} av
            {{ challengeStatus.challenge.questionCount }} frågor för att klara utmaningen.
          </p>
          <p v-else>
            Du har klarat {{ challengeStatus.qualification.correctQuestions }} av
            {{ challengeStatus.qualification.requiredCorrectAnswers }} olika frågor på nivå
            {{ challengeStatus.challenge.requiredDifficulty }} i den här kategorin.
            Fortsätt samla rätta svar för att låsa upp utmaningen!
          </p>
          <button
            v-if="challengeStatus.available && !pendingChallengeStart"
            class="button button-primary"
            type="button"
            :disabled="loading || auth.busy || !authReady"
            @click="startChallenge"
          >
            Starta utmaningen
          </button>
        </section>
        <div v-if="pendingChallengeStart && !loading && !needsLogin" class="answer-retry">
          <button
            class="button button-primary"
            type="button"
            :disabled="auth.busy || !authReady"
            @click="startChallenge"
          >
            Försök starta utmaningen igen
          </button>
        </div>
        <template v-if="screen === 'home' || (screen === 'result' && !isChallenge)">
          <p v-if="challengeStatusLoading && selectedTopicId && selectedDifficulty === 3" role="status">
            Kontrollerar historiska utmaningar…
          </p>
          <div v-else-if="challengeStatusError && selectedTopicId && selectedDifficulty === 3" role="alert">
            <p>{{ challengeStatusError }}</p>
            <button class="button button-secondary" type="button" @click="loadChallengeStatus">
              Kontrollera utmaningen igen
            </button>
          </div>
        </template>
      </template>
    </main>
    <footer class="footer-note">
      <span aria-hidden="true">✦</span> Små frågor, stora upptäckter
      <span aria-hidden="true">✦</span>
    </footer>
  </div>
</template>

<style scoped>
.challenge-active { align-content: center; }

.game-layout { width: min(100%, 880px); }
.game-content { min-width: 0; display: grid; justify-items: center; }

@media (min-width: 768px) {
  .game-layout.has-character {
    width: min(100%, 1180px);
    display: grid;
    grid-template-columns: minmax(0, 1fr) clamp(220px, 27vw, 320px);
    align-items: center;
    gap: clamp(16px, 2vw, 32px);
  }

  .has-character > .game-content { grid-area: 1 / 1; }
  .has-character > .challenge-character {
    grid-area: 1 / 2;
    flex-direction: column;
    width: 100%;
    margin: 0;
    padding: 0;
    gap: 0;
    text-align: center;
  }

  .has-character :deep(.caesar-portrait) {
    width: 100%;
    max-width: 300px;
    aspect-ratio: 3 / 4;
  }

  /* De breda transparenta kanterna får mindre plats; hela figuren syns. */
  .has-character :deep(.caesar-frame) { object-fit: cover; }
  .has-character :deep(.caesar-copy) { max-width: 100%; }
  .has-character :deep(.quiz-panel),
  .has-character :deep(.feedback-panel) {
    padding: clamp(24px, 3.5vw, 48px);
  }
}

.challenge-offer {
  margin-top: 24px;
  padding: 24px 30px;
  border-color: #e4c784;
  background: #fff9e9;
}

.challenge-offer h2 { margin: 0; color: #34415a; }
.challenge-offer p:not(.eyebrow) { color: #687188; line-height: 1.6; margin: 12px 0 20px; }
.challenge-context { width: min(100%, 880px); margin: 0 0 16px; color: #687188; text-align: center; }
.answer-retry, .achievement-retry { margin: 16px 0; text-align: center; }
.button:disabled { opacity: 0.6; cursor: not-allowed; transform: none; }

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

.level-unlock-notice {
  position: fixed;
  z-index: 21;
  top: 258px;
  right: max(24px, calc((100vw - 1120px) / 2));
  pointer-events: none;
}

.level-unlock-notice > * { pointer-events: auto; }

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

  .level-unlock-notice {
    top: 240px;
    right: 12px;
    left: 12px;
    display: grid;
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
