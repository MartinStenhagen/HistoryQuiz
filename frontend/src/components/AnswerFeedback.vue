<script setup>
defineProps({
  question: { type: Object, required: true },
  questionNumber: { type: Number, required: true },
  totalQuestions: { type: Number, required: true },
  isCorrect: { type: Boolean, required: true },
})

defineEmits(['next', 'home'])
</script>

<template>
  <section class="feedback-panel panel" aria-labelledby="feedback-title">
    <div class="quiz-topline">
      <button class="back-button" type="button" @click="$emit('home')">← Startsidan</button>
      <span class="question-count">Fråga {{ questionNumber }} av {{ totalQuestions }}</span>
    </div>
    <div class="progress-track" aria-hidden="true">
      <span :style="{ width: `${(questionNumber / totalQuestions) * 100}%` }"></span>
    </div>
    <div class="feedback-content" aria-live="polite">
      <div
        class="feedback-icon"
        :class="isCorrect ? 'is-correct' : 'is-incorrect'"
        aria-hidden="true"
      >
        {{ isCorrect ? '😊' : '🙂' }}
      </div>
      <p class="eyebrow">{{ isCorrect ? 'Snyggt jobbat!' : 'Bra försök!' }}</p>
      <h1 id="feedback-title" class="feedback-title">
        {{ isCorrect ? 'Rätt!' : 'Inte riktigt – vi lär oss!' }}
      </h1>
      <p class="answer-reveal">
        Rätt svar: <strong>{{ question.correctAnswer }}</strong>
      </p>
      <p class="explanation">{{ question.explanation }}</p>
      <button class="button button-primary" type="button" @click="$emit('next')">
        {{ questionNumber === totalQuestions ? 'Se resultat' : 'Nästa fråga' }}
        <span aria-hidden="true">→</span>
      </button>
    </div>
  </section>
</template>
