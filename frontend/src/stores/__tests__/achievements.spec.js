import { beforeEach, describe, expect, it } from 'vitest'
import { createPinia, setActivePinia } from 'pinia'
import { useAchievementsStore } from '../achievements'

describe('achievement unlock notifications', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('returns the first achievement as newly unlocked on the first answer', () => {
    const store = useAchievementsStore()

    const unlocked = store.recordAnswer(101, false)

    expect(unlocked.map((achievement) => achievement.code)).toEqual(['FIRST_ANSWER'])
  })

  it('returns a streak achievement only when its threshold is newly reached', () => {
    const store = useAchievementsStore()

    expect(store.recordAnswer(101, true)).toHaveLength(1)
    expect(store.recordAnswer(102, true)).toHaveLength(0)

    const unlocked = store.recordAnswer(103, true)

    expect(unlocked.map((achievement) => achievement.code)).toEqual(['THREE_IN_A_ROW'])
    expect(store.recordAnswer(104, true)).toHaveLength(0)
  })

  it('unlocks explorer after 10 different correct questions, not repeated answers', () => {
    const store = useAchievementsStore()

    for (let questionId = 1; questionId <= 9; questionId += 1) {
      store.recordAnswer(questionId, true)
    }

    expect(store.achievements.find((achievement) => achievement.code === 'TEN_UNIQUE_CORRECT').progress).toBe(9)
    const repeatedAnswerUnlocks = store.recordAnswer(9, true)
    expect(repeatedAnswerUnlocks.map((achievement) => achievement.code)).not.toContain('TEN_UNIQUE_CORRECT')

    const unlocked = store.recordAnswer(10, true)

    expect(unlocked.map((achievement) => achievement.code)).toContain('TEN_UNIQUE_CORRECT')
  })
})
