<script setup>
defineProps({
  question: { type: Object, required: true },
  questionNumber: { type: Number, required: true },
  totalQuestions: { type: Number, required: true },
})

defineEmits(['answer', 'home'])
</script>

<template>
  <section class="quiz-panel panel" aria-labelledby="question-title">
    <div class="quiz-topline">
      <button class="back-button" type="button" @click="$emit('home')">← Startsidan</button>
      <span class="question-count">Fråga {{ questionNumber }} av {{ totalQuestions }}</span>
    </div>
    <div
      class="progress-track"
      role="progressbar"
      :aria-valuenow="questionNumber"
      :aria-valuemin="1"
      :aria-valuemax="totalQuestions"
      :aria-label="`Fråga ${questionNumber} av ${totalQuestions}`"
    >
      <span :style="{ width: `${(questionNumber / totalQuestions) * 100}%` }"></span>
    </div>
    <p class="eyebrow question-eyebrow"><span aria-hidden="true">✦</span> Fundera och välj</p>
    <h1 id="question-title" class="question-title">{{ question.question }}</h1>
    <p class="choose-hint">Tryck på det svar du tror är rätt:</p>
    <div class="answers">
      <button
        v-for="(answer, index) in question.answers"
        :key="answer"
        class="answer-button"
        type="button"
        @click="$emit('answer', answer)"
      >
        <span class="answer-letter" aria-hidden="true">{{ String.fromCharCode(65 + index) }}</span>
        <span>{{ answer }}</span>
        <span class="answer-arrow" aria-hidden="true">›</span>
      </button>
    </div>
  </section>
</template>
