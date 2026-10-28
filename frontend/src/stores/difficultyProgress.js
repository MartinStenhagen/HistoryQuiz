import { defineStore } from 'pinia'
import { ref } from 'vue'

const STORAGE_KEY = 'historyQuiz.difficultyProgress'
const MAX_DIFFICULTY = 3

function readProgress() {
  if (typeof localStorage === 'undefined') return {}

  try {
    const savedProgress = JSON.parse(localStorage.getItem(STORAGE_KEY) || '{}')
    return savedProgress && typeof savedProgress === 'object' ? savedProgress : {}
  } catch {
    return {}
  }
}

export const useDifficultyProgressStore = defineStore('difficultyProgress', () => {
  const unlockedByTopic = ref(readProgress())

  function unlockedLevels(topicId) {
    if (topicId === null || topicId === undefined) return [1]

    const savedLevels = unlockedByTopic.value[String(topicId)]
    if (!Array.isArray(savedLevels)) return [1]

    return [...new Set([1, ...savedLevels])]
      .filter((level) => Number.isInteger(level) && level >= 1 && level <= MAX_DIFFICULTY)
      .sort((first, second) => first - second)
  }

  function isUnlocked(topicId, difficulty) {
    return unlockedLevels(topicId).includes(difficulty)
  }

  function unlockNextLevel(topicId, completedDifficulty) {
    if (
      topicId === null ||
      topicId === undefined ||
      !Number.isInteger(completedDifficulty) ||
      !isUnlocked(topicId, completedDifficulty) ||
      completedDifficulty >= MAX_DIFFICULTY
    ) {
      return null
    }

    const nextDifficulty = completedDifficulty + 1
    const levels = unlockedLevels(topicId)

    if (levels.includes(nextDifficulty)) return null

    unlockedByTopic.value[String(topicId)] = [...levels, nextDifficulty]
    persistProgress()

    return nextDifficulty
  }

  function persistProgress() {
    if (typeof localStorage === 'undefined') return

    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(unlockedByTopic.value))
    } catch {
      // Progress still works for the current session if storage is unavailable.
    }
  }

  return { unlockedLevels, isUnlocked, unlockNextLevel }
})
