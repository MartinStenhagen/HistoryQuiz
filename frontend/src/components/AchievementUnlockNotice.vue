<script setup>
import { onMounted, onUnmounted } from 'vue'

const props = defineProps({
  achievement: { type: Object, required: true },
})

const emit = defineEmits(['dismiss'])
let dismissTimer

onMounted(() => {
  dismissTimer = window.setTimeout(() => emit('dismiss'), 7000)
})

onUnmounted(() => {
  window.clearTimeout(dismissTimer)
})
</script>

<template>
  <section class="unlock-notice" role="status" aria-live="polite">
    <span class="celebration sparkle-one" aria-hidden="true">✦</span>
    <span class="celebration sparkle-two" aria-hidden="true">✧</span>
    <div class="unlock-icon" aria-hidden="true">{{ achievement.icon }}</div>
    <div class="unlock-copy">
      <p class="unlock-kicker">🎉 Ny utmärkelse upplåst!</p>
      <h2>{{ achievement.name }}</h2>
      <p>{{ achievement.description }}</p>
    </div>
    <button
      class="dismiss-button"
      type="button"
      :aria-label="`Stäng notis om ${achievement.name}`"
      @click="emit('dismiss')"
    >
      ×
    </button>
  </section>
</template>

<style scoped>
.unlock-notice {
  position: relative;
  display: grid;
  grid-template-columns: 58px minmax(0, 1fr) 30px;
  align-items: center;
  gap: 14px;
  width: min(410px, calc(100vw - 32px));
  overflow: hidden;
  border: 2px solid #f3c75f;
  border-radius: 22px;
  padding: 17px 16px;
  color: #fff;
  background: linear-gradient(135deg, #3f537c, #6c5c9c 58%, #d47663);
  box-shadow: 0 14px 36px rgba(39, 43, 73, 0.3), 0 0 0 5px rgba(255, 218, 123, 0.2);
  animation: unlock-arrive 520ms cubic-bezier(0.2, 1.4, 0.4, 1) both;
}

.unlock-icon {
  width: 58px;
  height: 58px;
  display: grid;
  place-items: center;
  border: 2px solid rgba(255, 255, 255, 0.82);
  border-radius: 19px;
  background: rgba(255, 240, 193, 0.22);
  font-size: 34px;
  animation: medal-wiggle 800ms ease-in-out 520ms 2;
}

.unlock-kicker {
  margin: 0 0 3px;
  color: #ffe59a;
  font-size: 12px;
  font-weight: 900;
  letter-spacing: 0.07em;
  text-transform: uppercase;
}

.unlock-copy h2 {
  margin: 0;
  color: #fff;
  font-size: 19px;
  line-height: 1.2;
}

.unlock-copy > p:last-child {
  margin: 4px 0 0;
  color: rgba(255, 255, 255, 0.88);
  font-size: 13px;
  line-height: 1.4;
}

.dismiss-button {
  align-self: start;
  border: 0;
  border-radius: 50%;
  width: 30px;
  height: 30px;
  color: white;
  background: rgba(255, 255, 255, 0.16);
  font: inherit;
  font-size: 25px;
  line-height: 1;
  cursor: pointer;
}

.dismiss-button:hover { background: rgba(255, 255, 255, 0.28); }
.dismiss-button:focus-visible { outline: 3px solid #ffe59a; outline-offset: 2px; }
.celebration { position: absolute; color: #ffe59a; pointer-events: none; }
.sparkle-one { top: 9px; left: 11px; font-size: 18px; }
.sparkle-two { bottom: 9px; left: 75px; font-size: 15px; }

@keyframes unlock-arrive {
  from { opacity: 0; transform: translateY(-18px) scale(0.92); }
  to { opacity: 1; transform: translateY(0) scale(1); }
}

@keyframes medal-wiggle {
  0%, 100% { transform: rotate(0); }
  25% { transform: rotate(-12deg) scale(1.06); }
  75% { transform: rotate(12deg) scale(1.06); }
}

@media (prefers-reduced-motion: reduce) {
  .unlock-notice, .unlock-icon { animation: none; }
}

@media (max-width: 600px) {
  .unlock-notice { grid-template-columns: 48px minmax(0, 1fr) 28px; gap: 11px; padding: 14px 12px; }
  .unlock-icon { width: 48px; height: 48px; border-radius: 16px; font-size: 29px; }
  .unlock-copy h2 { font-size: 17px; }
}
</style>
