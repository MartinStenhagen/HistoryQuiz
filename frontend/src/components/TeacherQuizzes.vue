<script setup>
import { onMounted, reactive, ref } from 'vue'
import { api } from '../api'
import { useAuthStore } from '../stores/auth'

const auth = useAuthStore()
const topics = ref([])
const quizzes = ref([])
const loading = ref(false)
const errorMessage = ref('')
const quizErrorMessage = ref('')
const successMessage = ref('')
const editingId = ref(null)

function createQuestion() {
  return {
    questionText: '',
    explanation: '',
    correctIndex: 0,
    options: ['', '', '', ''],
  }
}

function createForm() {
  return {
    title: '',
    description: '',
    topicId: '',
    difficulty: 1,
    questions: [createQuestion()],
  }
}

const form = reactive(createForm())
const accountOptions = () => ({ accountId: auth.user?.id })

function resetForm() {
  Object.assign(form, createForm())
  editingId.value = null
}

async function loadData() {
  loading.value = true
  errorMessage.value = ''
  quizErrorMessage.value = ''

  try {
    try {
      const topicData = await api('/api/teacher/quizzes/topics', accountOptions())
      topics.value = topicData.topics
    } catch (error) {
      console.error(error)
      const topicData = await api('/api/topics')
      topics.value = topicData.topics
    }

    try {
      const quizData = await api('/api/teacher/quizzes', accountOptions())
      quizzes.value = quizData.quizzes
    } catch (error) {
      console.error(error)
      quizErrorMessage.value = error.status === 401 || error.status === 403
        ? 'Logga in med ett lärarkonto för att visa och spara dina quiz.'
        : 'Quizhanteringen är inte tillgänglig i den aktuella backendversionen.'
    }
  } catch (error) {
    console.error(error)
    errorMessage.value = 'Kunde inte hämta ämnen. Försök igen.'
  } finally {
    loading.value = false
  }
}

function payload() {
  return {
    title: form.title,
    description: form.description,
    topicId: Number(form.topicId),
    difficulty: Number(form.difficulty),
    questions: form.questions.map(question => ({
      questionText: question.questionText,
      explanation: question.explanation,
      options: question.options.map((text, index) => ({
        text,
        isCorrect: index === question.correctIndex,
      })),
    })),
  }
}

async function saveDraft() {
  if (loading.value) return
  loading.value = true
  errorMessage.value = ''
  successMessage.value = ''

  try {
    const options = {
      ...accountOptions(),
      method: editingId.value === null ? 'POST' : 'PUT',
      body: payload(),
    }
    const path = editingId.value === null
      ? '/api/teacher/quizzes'
      : `/api/teacher/quizzes/${editingId.value}`
    await api(path, options)
    successMessage.value = 'Utkastet har sparats.'
    resetForm()
    await loadData()
  } catch (error) {
    console.error(error)
    errorMessage.value = error.message || 'Kunde inte spara quizet.'
  } finally {
    loading.value = false
  }
}

async function editDraft(quizId) {
  if (loading.value) return
  loading.value = true
  errorMessage.value = ''
  successMessage.value = ''

  try {
    const quiz = await api(`/api/teacher/quizzes/${quizId}`, accountOptions())
    editingId.value = quiz.id
    form.title = quiz.title
    form.description = quiz.description ?? ''
    form.topicId = String(quiz.topicId)
    form.difficulty = quiz.difficulty
    form.questions = quiz.questions.map(question => ({
      questionText: question.questionText,
      explanation: question.explanation,
      correctIndex: question.options.findIndex(option => option.isCorrect),
      options: question.options.map(option => option.text),
    }))
  } catch (error) {
    console.error(error)
    errorMessage.value = error.message || 'Kunde inte öppna utkastet.'
  } finally {
    loading.value = false
  }
}

async function changeStatus(quiz, action) {
  if (loading.value) return
  loading.value = true
  errorMessage.value = ''
  successMessage.value = ''

  try {
    await api(`/api/teacher/quizzes/${quiz.id}/${action}`, {
      ...accountOptions(),
      method: 'POST',
    })
    successMessage.value = action === 'publish'
      ? 'Quizet är publicerat och elever kan nu spela det.'
      : 'Quizet har arkiverats och går inte längre att spela.'
    await loadData()
  } catch (error) {
    console.error(error)
    errorMessage.value = error.message || 'Kunde inte ändra quizets status.'
  } finally {
    loading.value = false
  }
}

onMounted(loadData)
</script>

<template>
  <section class="quiz-management panel" aria-labelledby="teacher-quizzes-title">
    <h2 id="teacher-quizzes-title">Mina quiz</h2>
    <p class="intro">Skapa egna historiefrågor, spara quizet som utkast och publicera när det är klart.</p>

    <p v-if="errorMessage" role="alert">{{ errorMessage }}</p>
    <p v-if="quizErrorMessage" role="alert">{{ quizErrorMessage }}</p>
    <p v-if="successMessage" role="status">{{ successMessage }}</p>
    <p v-if="loading && quizzes.length === 0" role="status">Hämtar quiz…</p>

    <section class="quiz-list" aria-label="Dina quiz">
      <article v-for="quiz in quizzes" :key="quiz.id" class="quiz-item">
        <div>
          <h3>{{ quiz.title }}</h3>
          <p>{{ quiz.topicName }} · Nivå {{ quiz.difficulty }} · {{ quiz.questionCount }} frågor</p>
          <p>Status: {{ { draft: 'Utkast', published: 'Publicerat', archived: 'Arkiverat' }[quiz.status] }}</p>
        </div>
        <div class="quiz-actions">
          <button
            v-if="quiz.status === 'draft'"
            class="button button-secondary"
            type="button"
            :disabled="loading"
            @click="editDraft(quiz.id)"
          >
            Redigera utkast
          </button>
          <button
            v-if="quiz.status === 'draft'"
            class="button button-primary"
            type="button"
            :disabled="loading || quiz.questionCount === 0"
            @click="changeStatus(quiz, 'publish')"
          >
            Publicera
          </button>
          <button
            v-if="quiz.status === 'published'"
            class="button button-secondary"
            type="button"
            :disabled="loading"
            @click="changeStatus(quiz, 'archive')"
          >
            Arkivera
          </button>
        </div>
      </article>
      <p v-if="!loading && quizzes.length === 0">Du har inte skapat några quiz ännu.</p>
    </section>

    <form class="quiz-form" @submit.prevent="saveDraft">
      <h3>{{ editingId === null ? 'Skapa quiz' : 'Redigera utkast' }}</h3>
      <label for="quiz-title">Namn på quizet</label>
      <input id="quiz-title" v-model.trim="form.title" maxlength="100" required />

      <label for="quiz-description">Beskrivning (valfri)</label>
      <textarea id="quiz-description" v-model.trim="form.description" maxlength="500" rows="2" />

      <label for="quiz-topic">Ämne</label>
      <select id="quiz-topic" v-model="form.topicId" required>
        <option disabled value="">Välj ämne</option>
        <option v-for="topic in topics" :key="topic.id" :value="String(topic.id)">
          {{ topic.name }}
        </option>
      </select>

      <label for="quiz-difficulty">Svårighetsgrad</label>
      <select id="quiz-difficulty" v-model.number="form.difficulty">
        <option :value="1">Nivå 1</option>
        <option :value="2">Nivå 2</option>
        <option :value="3">Nivå 3</option>
      </select>

      <fieldset v-for="(question, questionIndex) in form.questions" :key="questionIndex" class="question-form">
        <legend>Fråga {{ questionIndex + 1 }}</legend>
        <label :for="`question-${questionIndex}`">Frågetext</label>
        <textarea
          :id="`question-${questionIndex}`"
          v-model.trim="question.questionText"
          maxlength="1000"
          rows="2"
          required
        />
        <label :for="`explanation-${questionIndex}`">Förklaring till rätt svar</label>
        <textarea
          :id="`explanation-${questionIndex}`"
          v-model.trim="question.explanation"
          maxlength="2000"
          rows="2"
          required
        />

        <p>Fyll i fyra svar och markera exakt ett rätt svar:</p>
        <div v-for="(option, optionIndex) in question.options" :key="optionIndex" class="option-form">
          <input
            :id="`option-${questionIndex}-${optionIndex}`"
            v-model.trim="question.options[optionIndex]"
            :aria-label="`Svar ${optionIndex + 1} till fråga ${questionIndex + 1}`"
            maxlength="500"
            required
          />
          <label :for="`correct-${questionIndex}-${optionIndex}`">
            <input
              :id="`correct-${questionIndex}-${optionIndex}`"
              v-model="question.correctIndex"
              type="radio"
              :name="`correct-${questionIndex}`"
              :value="optionIndex"
              required
            />
            Rätt svar
          </label>
        </div>
        <button
          v-if="form.questions.length > 1"
          class="back-button"
          type="button"
          :disabled="loading"
          @click="form.questions.splice(questionIndex, 1)"
        >
          Ta bort frågan
        </button>
      </fieldset>

      <button
        class="button button-secondary"
        type="button"
        :disabled="loading || form.questions.length >= 20"
        @click="form.questions.push(createQuestion())"
      >
        Lägg till fråga
      </button>
      <div class="quiz-form-actions">
        <button class="button button-primary" type="submit" :disabled="loading || topics.length === 0">
          {{ loading ? 'Sparar…' : 'Spara utkast' }}
        </button>
        <button
          v-if="editingId !== null"
          class="button button-secondary"
          type="button"
          :disabled="loading"
          @click="resetForm"
        >
          Avbryt redigering
        </button>
      </div>
    </form>
  </section>
</template>

<style scoped>
.quiz-management {
  display: grid;
  gap: 18px;
  padding: 24px;
}

.quiz-management h2,
.quiz-management h3,
.quiz-management p {
  margin: 0;
}

.quiz-list,
.quiz-form {
  display: grid;
  gap: 14px;
}

.quiz-item,
.question-form {
  border: 1px solid #e8e3d9;
  border-radius: 14px;
  padding: 16px;
}

.quiz-item,
.quiz-actions,
.quiz-form-actions {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.quiz-item h3 {
  color: #34415a;
}

.quiz-item p {
  margin-top: 5px;
  color: #687188;
  font-size: 13px;
}

.quiz-actions {
  justify-content: flex-end;
  flex-wrap: wrap;
}

.quiz-form {
  border-top: 1px solid #e8e3d9;
  padding-top: 20px;
}

.quiz-form input:not([type='radio']),
.quiz-form textarea,
.quiz-form select {
  width: 100%;
  min-width: 0;
  border: 1px solid #999;
  border-radius: 8px;
  padding: 10px;
  color: inherit;
  background: #fff;
  font: inherit;
}

.question-form {
  display: grid;
  gap: 10px;
}

.question-form legend {
  padding: 0 6px;
  color: #34415a;
  font-weight: 800;
}

.option-form {
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto;
  align-items: center;
  gap: 12px;
}

.option-form label {
  display: flex;
  align-items: center;
  gap: 6px;
  white-space: nowrap;
}

@media (max-width: 700px) {
  .quiz-item,
  .quiz-form-actions {
    align-items: stretch;
    flex-direction: column;
  }

  .quiz-actions {
    justify-content: flex-start;
  }

  .option-form {
    grid-template-columns: 1fr;
  }
}
</style>
