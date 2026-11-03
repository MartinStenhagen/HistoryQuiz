<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'

const props = defineProps({
  state: {
    type: String,
    default: 'idle',
    validator: value => ['idle', 'correct', 'incorrect'].includes(value),
  },
  reactionKey: { type: String, default: '' },
})

const reactions = {
  idle: { frames: ['idle'], message: 'Ta din tid. Jag tror på dig!' },
  correct: { frames: ['idle', 'correct-prep', 'correct'], message: 'Strålande! Bra jobbat!' },
  incorrect: {
    frames: ['idle', 'incorrect-prep', 'incorrect'],
    message: 'Bra försök! Vi lär oss tillsammans.',
  },
}
const state = computed(() => Object.hasOwn(reactions, props.state) ? props.state : 'idle')
const current = computed(() => reactions[state.value])
const loadedFrames = ref(new Set())
const failedFrames = ref(new Set())
const preloadedImages = []
const ready = computed(() => current.value.frames.every(frame => loadedFrames.value.has(frame)))

// Vänta på hela sekvensen. Om en bild saknas visas en statisk slutpose.
const frames = computed(() => {
  if (ready.value) return current.value.frames
  const lastFrame = current.value.frames.at(-1)
  if (current.value.frames.some(frame => failedFrames.value.has(frame)) && loadedFrames.value.has(lastFrame)) {
    return [lastFrame]
  }
  return ['idle']
})

function imageSource(frame) {
  return `${import.meta.env.BASE_URL}characters/caesar/${frame}.png`
}

onMounted(() => {
  const allFrames = new Set(Object.values(reactions).flatMap(reaction => reaction.frames))
  for (const frame of allFrames) {
    const image = new Image()
    image.onload = () => loadedFrames.value.add(frame)
    image.onerror = () => failedFrames.value.add(frame)
    preloadedImages.push(image)
    image.src = imageSource(frame)
  }
})

onBeforeUnmount(() => {
  for (const image of preloadedImages) {
    image.onload = null
    image.onerror = null
  }
})
</script>

<template>
  <section class="challenge-character" aria-label="Julius Caesar" :data-state="state">
    <div class="caesar-portrait" aria-hidden="true">
      <!-- En ny nyckel avbryter den gamla animationen och startar den nya från början. -->
      <div
        :key="`${reactionKey}:${state}:${ready}`"
        class="caesar-motion"
        :class="{ 'is-ready': ready }"
        :data-state="state"
      >
        <template v-for="(frame, index) in frames" :key="frame">
          <img
            v-if="!failedFrames.has(frame)"
            class="caesar-frame"
            :class="{
              'is-start': frames.length > 1 && index === 0,
              'is-middle': frames.length > 1 && index === 1,
              'is-final': index === frames.length - 1,
            }"
            :src="imageSource(frame)"
            alt=""
            width="1254"
            height="1254"
            draggable="false"
          />
        </template>
      </div>
    </div>
    <div class="caesar-copy">
      <strong>Julius Caesar</strong>
      <p>{{ current.message }}</p>
    </div>
  </section>
</template>

<style scoped src="../assets/caesar.css"></style>
