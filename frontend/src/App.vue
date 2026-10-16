<script setup>
import { computed, onMounted, ref } from 'vue'
import AnswerFeedback from './components/AnswerFeedback.vue'
import QuizQuestion from './components/QuizQuestion.vue'
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
      <span class="age-badge"><span aria-hidden="true">✦</span> Historia för nyfikna</span>
    </header>

    <main>
      <p v-if="loading" role="status">
        {{ screen === 'quiz' ? 'Rättar svaret…' : 'Hämtar frågor…' }}
      </p>

      <p v-if="errorMessage" role="alert">
        {{ errorMessage }}
      </p>
      <template v-if="screen === 'home'">
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
      :topics="topics"
      :selected-topic-id="selectedTopicId"
      :disabled="loading || topicsLoading"
      @topic-change="selectedTopicId = $event"
      @start="startQuiz"
    />
  </template>
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
