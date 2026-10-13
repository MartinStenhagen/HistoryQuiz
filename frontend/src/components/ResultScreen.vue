<script setup>
defineProps({
  score: { type: Number, required: true },
  totalQuestions: { type: Number, required: true },
})

defineEmits(['restart', 'home'])
</script>

<template>
  <section class="result-panel panel" aria-labelledby="result-title">
    <div class="result-confetti" aria-hidden="true">✦　✧　✦</div>
    <div class="result-medal" aria-hidden="true">🏆</div>
    <p class="eyebrow">Tidsresan är klar!</p>
    <h1 id="result-title" class="result-title">
      {{ score >= 4 ? 'Vilken stjärna!' : score >= 2 ? 'Bra kämpat!' : 'Snyggt jobbat!' }}
    </h1>
    <p class="result-score">Du fick <strong>{{ score }} av {{ totalQuestions }}</strong> rätt!</p>
    <p class="explanation">
      Du har lärt dig massor om historia. Nyfikenhet är det bästa sättet att upptäcka mer!
    </p>
    <div class="result-actions">
      <button class="button button-primary" type="button" @click="$emit('restart')">
        Spela igen <span aria-hidden="true">↻</span>
      </button>
      <button class="button button-secondary" type="button" @click="$emit('home')">Till startsidan</button>
    </div>
  </section>
</template>
