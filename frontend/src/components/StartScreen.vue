<script setup>
import { ref } from 'vue'
import loginAuthorization from './loginAuthorization.vue'
defineProps({
  topics: {
    type: Array,
    required: true,
  },
  selectedTopicId: {
    type: Number,
    default: null,
  },
  selectedDifficulty: { type: Number, default: 1 },
  unlockedDifficulties: { type: Array, default: () => [1] },
  disabled: {
    type: Boolean,
    default: false,
  },
  isAuthenticated: {
    type: Boolean,
    default: false,
  },
  currentUser: {
    type: Object,
    default: null,
  },
  accountBusy: { type: Boolean, default: false },
})

const handleLoginSuccess = (userData) => {
  showLoginPopup.value = false
  emit('login-success', userData)
}

const showLoginPopup = ref(false)

const emit = defineEmits(['start', 'topic-change', 'difficulty-change', 'register', 'logout', 'login-success'])
</script>

<template>
  <section class="welcome panel" aria-labelledby="welcome-title">
    <div class="welcome-copy">
      <p class="eyebrow"><span aria-hidden="true">✦</span> Dags för en tidsresa!</p>
      <h1 id="welcome-title">
        {{
          isAuthenticated
            ? `Välkommen, ${currentUser?.displayName || 'historiedetektiv'}!`
            : 'Hej, historiedetektiv!'
        }}
      </h1>
      <p class="intro">
        Följ med på en rolig resa bakåt i tiden. Svara på historiefrågor och upptäck spännande saker
        från förr. Du kan ta det precis i din egen takt!
      </p>
      <div class="topic-picker">
        <label for="topic-select">Välj en kategori i listan:</label>

        <select
          id="topic-select"
          :value="selectedTopicId ?? ''"
          :disabled="disabled || topics.length === 0"
          @change="$emit('topic-change', Number($event.target.value))"
        >
          <option disabled value="">Välj ett ämne</option>

          <option v-for="topic in topics" :key="topic.id" :value="topic.id">
            {{ topic.name }}
          </option>
        </select>
      </div>

      <fieldset class="difficulty-picker" :disabled="disabled || selectedTopicId === null">
        <legend>Välj svårighetsgrad</legend>
        <div class="difficulty-options">
          <button
            v-for="difficulty in [1, 2, 3]"
            :key="difficulty"
            class="difficulty-option"
            :class="{
              'is-selected': selectedDifficulty === difficulty,
              'is-locked': !unlockedDifficulties.includes(difficulty),
            }"
            type="button"
            :disabled="disabled || selectedTopicId === null || !unlockedDifficulties.includes(difficulty)"
            :aria-pressed="selectedDifficulty === difficulty"
            @click="emit('difficulty-change', difficulty)"
          >
            <span class="difficulty-icon" aria-hidden="true">
              {{ unlockedDifficulties.includes(difficulty) ? ['🌱', '🧭', '🏆'][difficulty - 1] : '🔒' }}
            </span>
            <span class="difficulty-label">Nivå {{ difficulty }}</span>
            <span class="difficulty-state">
              {{ unlockedDifficulties.includes(difficulty) ? (difficulty === 1 ? 'Start' : 'Upplåst') : 'Låst' }}
            </span>
          </button>
        </div>
        <p class="difficulty-hint">
          Klara alla frågor rätt på en nivå för att låsa upp nästa i samma kategori. Framsteg sparas på den här enheten.
        </p>
      </fieldset>

      <button
        class="button button-primary start-button"
        type="button"
        :disabled="disabled || selectedTopicId === null || topics.length === 0"
        @click="$emit('start')"
      >
        Börja spela <span aria-hidden="true">→</span>
      </button>
      <section class="login_container">
        <template v-if="!isAuthenticated">
          <section class="auth-links">
            <button
              class="back-button register-link"
              type="button"
              :disabled="disabled || accountBusy"
              @click="showLoginPopup = !showLoginPopup"
            >
              {{ showLoginPopup ? 'Stäng' : 'Logga in' }}
            </button>
            <section v-if="showLoginPopup" class="login-popup">
              <loginAuthorization :disabled="disabled" @login-success="handleLoginSuccess" />
            </section>
            <button
              class="back-button register-link"
              type="button"
              :disabled="disabled || accountBusy"
              @click="$emit('register')"
            >
              Skapa konto (valfritt)
            </button>
          </section>
        </template>

        <section v-else>
          <button
            class="back-button register-link"
            type="button"
            :disabled="disabled || accountBusy"
            @click="$emit('logout')"
          >
            Logga ut
          </button>
        </section>
      </section>
      <p class="reassurance">
        <span aria-hidden="true">☀</span> Ingen tidspress – här lär vi oss tillsammans.
      </p>
    </div>
    <div class="welcome-art" aria-hidden="true">
      <span class="art-spark spark-one">✦</span>
      <span class="art-spark spark-two">✧</span>
      <div class="sun">☼</div>
      <div class="art-book">📜</div>
      <div class="art-caption">En liten resa<br />genom historien</div>
    </div>
  </section>
</template>

<style scoped>
.topic-picker {
  display: grid;
  gap: 8px;
  margin: 24px 0;
}

.topic-picker select {
  width: 100%;
  min-width: 0;
  padding: 12px;
  border: 1px solid #999;
  border-radius: 8px;
  color: inherit;
  background: #fff;
  font: inherit;
}

.topic-picker select:focus-visible {
  outline: 3px solid #e5a33c;
  outline-offset: 3px;
}

.difficulty-picker {
  min-width: 0;
  margin: 0 0 23px;
  border: 0;
  padding: 0;
}

.difficulty-picker legend {
  margin-bottom: 10px;
  color: #34415a;
  font-size: 15px;
  font-weight: 800;
}

.difficulty-options {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 9px;
}

.difficulty-option {
  min-height: 91px;
  display: grid;
  justify-items: center;
  align-content: center;
  gap: 3px;
  border: 2px solid #e8e3d9;
  border-radius: 15px;
  padding: 8px 5px;
  color: #536078;
  background: #fff;
  font: inherit;
  cursor: pointer;
  transition: transform 150ms ease, border-color 150ms ease, background 150ms ease;
}

.difficulty-option:not(:disabled):hover { transform: translateY(-2px); border-color: #d6a25f; }
.difficulty-option.is-selected { border-color: #e1764e; background: #fff4e9; box-shadow: 0 3px 0 #f1d5bb; }
.difficulty-option.is-locked { color: #8d91a0; background: #f2f1ee; }
.difficulty-option:disabled { cursor: not-allowed; }
.difficulty-option:focus-visible { outline: 3px solid #e5a33c; outline-offset: 2px; }
.difficulty-icon { font-size: 21px; line-height: 1.1; }
.difficulty-label { color: #34415a; font-size: 13px; font-weight: 900; }
.difficulty-state { font-size: 11px; }
.difficulty-hint { margin: 9px 0 0; color: #788196; font-size: 12px; line-height: 1.4; }

.start-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.register-link {
  display: block;
  margin-top: 20px;
}

@media (max-width: 700px) {
  .difficulty-options { gap: 6px; }
  .difficulty-option { min-height: 82px; }
}
</style>
