<script setup>
import { storeToRefs } from 'pinia'
import { watch } from 'vue'
import { useAchievementsStore } from '../stores/achievements'
import { useAuthStore } from '../stores/auth'
import LoginAuthorization from '../components/loginAuthorization.vue'

const auth = useAuthStore()
const achievementsStore = useAchievementsStore()
const { achievements, unlockedCount, statistics, loading, error } = storeToRefs(achievementsStore)

watch(
  () => [auth.status, auth.version],
  () => {
    void achievementsStore.load()
  },
  { immediate: true },
)

function progressPercent(achievement) {
  return Math.min((achievement.progress / achievement.target) * 100, 100)
}
</script>

<template>
  <section class="achievements-page" aria-labelledby="achievements-title">
    <div class="achievements-heading">
      <div>
        <p class="achievements-eyebrow">
          <span aria-hidden="true">✦</span> Samla på historiska bedrifter
        </p>
        <h1 id="achievements-title">Mina utmärkelser</h1>
        <p class="achievements-intro">
          Varje fråga du provar tar dig ett steg närmare nästa märke!
        </p>
      </div>
      <div
        v-if="auth.isAuthenticated && !loading && !error"
        class="unlocked-summary"
        aria-label="Antal upplåsta utmärkelser"
      >
        <span class="summary-icon" aria-hidden="true">🏅</span>
        <span
          ><strong>{{ unlockedCount }} av {{ achievements.length }}</strong
          ><small>upplåsta</small></span
        >
      </div>
    </div>

    <p v-if="auth.status === 'checking'" role="status">Kontrollerar inloggningen…</p>
    <div v-else-if="auth.status === 'error'" role="alert">
      <p>{{ auth.error }}</p>
      <button class="button button-secondary" @click="auth.restore">Försök igen</button>
    </div>
    <div v-else-if="!auth.isAuthenticated">
      <p class="account-notice">Logga in för att spara dina framsteg och samla utmärkelser.</p>
      <LoginAuthorization />
    </div>
    <p v-else-if="loading" role="status">Hämtar dina utmärkelser…</p>
    <div v-else-if="error" role="alert">
      <p>{{ error }}</p>
      <button class="button button-secondary" @click="achievementsStore.load">Försök igen</button>
    </div>
    <template v-else>
      <p v-if="statistics" class="account-notice">
        {{ statistics.totalAnswers }} svar · {{ statistics.totalCorrect }} rätt ·
        {{ statistics.uniqueCorrect }} olika frågor rätt · Bästa följd:
        {{ statistics.bestStreak }} rätt i rad
      </p>
      <p v-if="achievements.length === 0">Det finns inga utmärkelser att samla just nu.</p>

      <div class="achievement-grid">
        <article
          v-for="achievement in achievements"
          :key="achievement.code"
          class="achievement-card"
          :class="{ 'is-unlocked': achievement.unlocked }"
        >
          <div class="achievement-card-top">
            <div class="achievement-icon" aria-hidden="true">{{ achievement.icon }}</div>
            <span class="achievement-status" :class="{ 'status-unlocked': achievement.unlocked }">
              {{ achievement.unlocked ? 'Upplåst!' : 'På väg' }}
            </span>
          </div>
          <h2>{{ achievement.name }}</h2>
          <p class="achievement-description">{{ achievement.description }}</p>
          <div
            class="achievement-progress"
            role="progressbar"
            :aria-label="`Framsteg för ${achievement.name}`"
            :aria-valuenow="achievement.progress"
            :aria-valuemin="0"
            :aria-valuemax="achievement.target"
          >
            <div class="progress-track">
              <span :style="{ width: `${progressPercent(achievement)}%` }"></span>
            </div>
            <span class="progress-count"
              >{{ achievement.progress }} / {{ achievement.target }}</span
            >
          </div>
        </article>
      </div>

      <p class="encouragement">
        <span aria-hidden="true">✨</span> Fortsätt vara nyfiken – nästa märke väntar!
      </p>
    </template>
  </section>
</template>

<style scoped>
.achievements-page {
  width: min(100%, 980px);
  align-self: start;
  padding: 12px 0 20px;
}

.achievements-heading {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24px;
  margin-bottom: 20px;
}

.achievements-eyebrow {
  margin: 0 0 10px;
  color: #c86b49;
  font-size: 13px;
  font-weight: 800;
  letter-spacing: 0.06em;
  text-transform: uppercase;
}

.achievements-eyebrow span {
  color: #e8aa3d;
}
.achievements-heading h1 {
  margin: 0;
  color: #25324b;
  font-size: clamp(30px, 4vw, 42px);
  line-height: 1.15;
}
.achievements-intro {
  margin: 10px 0 0;
  color: #687188;
  font-size: 17px;
  line-height: 1.5;
}

.unlocked-summary {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 0 0 auto;
  border: 1px solid #f0dfb8;
  border-radius: 18px;
  padding: 13px 17px;
  background: #fff7e5;
  color: #4b5369;
}

.summary-icon {
  font-size: 29px;
}
.unlocked-summary strong,
.unlocked-summary small {
  display: block;
}
.unlocked-summary strong {
  color: #9a6828;
  font-size: 16px;
}
.unlocked-summary small {
  margin-top: 2px;
  color: #817660;
  font-size: 13px;
}

.account-notice {
  display: flex;
  align-items: center;
  gap: 9px;
  margin: 0 0 18px;
  border: 1px solid #d9e7f4;
  border-radius: 12px;
  padding: 10px 14px;
  background: #f2f8ff;
  color: #52677e;
  font-size: 14px;
  line-height: 1.45;
}

.achievement-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
}

.achievement-card {
  min-height: 190px;
  border: 2px solid #e9e5dd;
  border-radius: 20px;
  padding: 19px 21px 17px;
  background: rgba(255, 255, 255, 0.9);
  box-shadow: 0 5px 0 rgba(87, 77, 55, 0.05);
}

.achievement-card.is-unlocked {
  border-color: #c4e4ce;
  background: linear-gradient(140deg, #f3fbf2, #fff 75%);
}
.achievement-card-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}
.achievement-icon {
  width: 52px;
  height: 52px;
  display: grid;
  place-items: center;
  border-radius: 17px;
  background: #f1eee8;
  font-size: 29px;
}
.is-unlocked .achievement-icon {
  background: #ddf2df;
}
.achievement-status {
  border-radius: 99px;
  padding: 6px 11px;
  background: #f0eee9;
  color: #72788a;
  font-size: 12px;
  font-weight: 800;
}
.status-unlocked {
  background: #dff3e3;
  color: #347149;
}
.achievement-card h2 {
  margin: 13px 0 5px;
  color: #303d55;
  font-size: 19px;
}
.achievement-description {
  min-height: 22px;
  margin: 0 0 14px;
  color: #70798b;
  font-size: 14px;
  line-height: 1.5;
}
.achievement-progress {
  display: flex;
  align-items: center;
  gap: 11px;
}
.progress-track {
  height: 9px;
  flex: 1;
  overflow: hidden;
  border-radius: 99px;
  background: #ecebe7;
}
.progress-track span {
  height: 100%;
  display: block;
  border-radius: inherit;
  background: linear-gradient(90deg, #efb959, #e68155);
  transition: width 250ms ease;
}
.is-unlocked .progress-track span {
  background: linear-gradient(90deg, #7dbe8e, #55a677);
}
.progress-count {
  min-width: 42px;
  color: #687188;
  font-size: 13px;
  font-weight: 800;
  text-align: right;
}

.encouragement {
  margin: 19px 0 0;
  color: #7c8497;
  font-size: 14px;
  text-align: center;
}
.encouragement span {
  color: #e6a43c;
}

@media (max-width: 650px) {
  .achievements-page {
    padding-top: 4px;
  }
  .achievements-heading {
    align-items: flex-start;
  }
  .unlocked-summary {
    gap: 8px;
    padding: 10px 12px;
  }
  .summary-icon {
    font-size: 24px;
  }
  .unlocked-summary strong {
    font-size: 14px;
  }
  .achievements-intro {
    font-size: 15px;
  }
  .achievement-grid {
    grid-template-columns: 1fr;
    gap: 12px;
  }
  .achievement-card {
    min-height: auto;
  }
}

@media (max-width: 420px) {
  .achievements-heading {
    flex-direction: column;
    gap: 14px;
  }
}
</style>
