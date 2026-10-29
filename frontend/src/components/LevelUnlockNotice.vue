<script setup>
import { onMounted, onUnmounted } from 'vue'

defineProps({
  categoryName: { type: String, required: true },
  difficulty: { type: Number, required: true },
})

const emit = defineEmits(['dismiss'])
let dismissTimer

onMounted(() => {
  dismissTimer = window.setTimeout(() => emit('dismiss'), 7000)
})

onUnmounted(() => window.clearTimeout(dismissTimer))
</script>

<template>
  <section class="level-unlock-toast" role="status" aria-live="polite">
    <div class="unlock-emblem" aria-hidden="true">⭐</div>
    <div class="unlock-copy">
      <p class="unlock-kicker">🎉 Snyggt jobbat!</p>
      <h2>Nivå {{ difficulty }} upplåst!</h2>
      <p>Du klarade {{ categoryName }}. Nu väntar en större utmaning!</p>
    </div>
    <button
      class="dismiss-button"
      type="button"
      aria-label="Stäng nivånotisen"
      @click="emit('dismiss')"
    >
      ×
    </button>
  </section>
</template>

<style scoped>
.level-unlock-toast {
  display: grid;
  grid-template-columns: 54px minmax(0, 1fr) 30px;
  align-items: center;
  gap: 13px;
  width: min(410px, calc(100vw - 32px));
  border: 2px solid #f3c75f;
  border-radius: 22px;
  padding: 16px;
  color: white;
  background: linear-gradient(135deg, #3f537c, #6c5c9c 58%, #d47663);
  box-shadow: 0 14px 36px rgba(39, 43, 73, 0.3), 0 0 0 5px rgba(255, 218, 123, 0.2);
  animation: level-arrive 520ms cubic-bezier(0.2, 1.4, 0.4, 1) both;
}

.unlock-emblem {
  width: 54px;
  height: 54px;
  display: grid;
  place-items: center;
  border: 2px solid rgba(255, 255, 255, 0.82);
  border-radius: 18px;
  background: rgba(255, 240, 193, 0.22);
  font-size: 30px;
  animation: star-pop 700ms ease-in-out 500ms 2;
}

.unlock-kicker { margin: 0 0 3px; color: #ffe59a; font-size: 12px; font-weight: 900; letter-spacing: 0.07em; text-transform: uppercase; }
.unlock-copy h2 { margin: 0; color: white; font-size: 19px; line-height: 1.2; }
.unlock-copy > p:last-child { margin: 4px 0 0; color: rgba(255, 255, 255, 0.9); font-size: 13px; line-height: 1.4; }
.dismiss-button { align-self: start; width: 30px; height: 30px; border: 0; border-radius: 50%; color: white; background: rgba(255, 255, 255, 0.16); font: inherit; font-size: 25px; line-height: 1; cursor: pointer; }
.dismiss-button:hover { background: rgba(255, 255, 255, 0.28); }
.dismiss-button:focus-visible { outline: 3px solid #ffe59a; outline-offset: 2px; }

@keyframes level-arrive {
  from { opacity: 0; transform: translateY(-18px) scale(0.92); }
  to { opacity: 1; transform: translateY(0) scale(1); }
}

@keyframes star-pop {
  0%, 100% { transform: scale(1) rotate(0); }
  50% { transform: scale(1.18) rotate(12deg); }
}

@media (prefers-reduced-motion: reduce) {
  .level-unlock-toast, .unlock-emblem { animation: none; }
}
</style>
