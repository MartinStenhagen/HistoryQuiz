<script setup>
defineProps({
  score: { type: Number, required: true },
  totalQuestions: { type: Number, required: true },
  challenge: { type: Object, default: null },
  disabled: { type: Boolean, default: false },
})

defineEmits(['restart', 'home'])
</script>

<template>
  <section class="result-panel panel" aria-labelledby="result-title">
    <div class="result-confetti" aria-hidden="true">✦　✧　✦</div>
    <div class="result-medal" aria-hidden="true">
      {{ challenge && challenge.status !== 'passed' ? '🌱' : '🏆' }}
    </div>
    <p class="eyebrow">{{ challenge ? 'Utmaningen är klar!' : 'Tidsresan är klar!' }}</p>
    <h1 id="result-title" class="result-title">
      {{
        challenge
          ? (challenge.status === 'passed' ? 'Utmaningen klarad!' : 'Bra kämpat – försök igen!')
        : score === totalQuestions
          ? 'Vilken stjärna!'
        : score >= totalQuestions / 2
        ? 'Bra kämpat!'
        : 'Snyggt jobbat!'
      }}
    </h1>
    <p class="result-score">Du fick <strong>{{ score }} av {{ totalQuestions }}</strong> rätt!</p>
    <p v-if="challenge" class="explanation">
      {{ challenge.status === 'passed'
        ? `Du klarade utmaningen med ${challenge.characterName}!`
        : `Du behöver ${challenge.correctToPass} rätt för att klara utmaningen. Du kan försöka igen!` }}
    </p>
    <p v-else class="explanation">
      Du har lärt dig massor om historia. Nyfikenhet är det bästa sättet att upptäcka mer!
    </p>
    <div class="result-actions">
      <button class="button button-primary" type="button" :disabled="disabled" @click="$emit('restart')">
        {{ challenge ? 'Försök med utmaningen igen' : 'Spela igen' }} <span aria-hidden="true">↻</span>
      </button>
      <button class="button button-secondary" type="button" :disabled="disabled" @click="$emit('home')">Till startsidan</button>
    </div>
  </section>
</template>
