import { computed, ref } from 'vue'
import { defineStore } from 'pinia'
import { achievementDefinitions } from '../data/demoAchievements'

export const useAchievementsStore = defineStore('achievements', () => {
  const answers = ref([])

  function recordAnswer(questionId, isCorrect) {
    answers.value.push({
      questionId,
      isCorrect,
    })
  }

  const achievements = computed(() => {
    const correctAnswers = answers.value.filter(
      (answer) => answer.isCorrect
    )

    const uniqueCorrectQuestions = new Set(
      correctAnswers.map((answer) => answer.questionId)
    )

    let currentStreak = 0
    let bestStreak = 0

    for (const answer of answers.value) {
      if (answer.isCorrect) {
        currentStreak += 1
        bestStreak = Math.max(bestStreak, currentStreak)
      } else {
        currentStreak = 0
      }
    }

    const progressByCode = {
      FIRST_ANSWER: answers.value.length,
      TEN_CORRECT: correctAnswers.length,
      TEN_UNIQUE_CORRECT: uniqueCorrectQuestions.size,
      THREE_IN_A_ROW: bestStreak,
    }

    return achievementDefinitions.map((achievement) => ({
      ...achievement,
      progress: Math.min(
        progressByCode[achievement.code] ?? 0,
        achievement.target
      ),
    }))
  })

  const unlockedCount = computed(
    () => achievements.value.filter(
      (achievement) => achievement.progress >= achievement.target
    ).length
  )

  return {
    answers,
    achievements,
    unlockedCount,
    recordAnswer,
  }
})
