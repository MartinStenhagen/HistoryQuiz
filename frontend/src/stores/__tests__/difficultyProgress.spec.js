import { beforeEach, describe, expect, it } from 'vitest'
import { createPinia, setActivePinia } from 'pinia'
import { useDifficultyProgressStore } from '../difficultyProgress'

describe('difficulty progress by topic', () => {
  beforeEach(() => {
    localStorage.clear()
    setActivePinia(createPinia())
  })

  it('starts every category at level one and unlocks levels sequentially', () => {
    const progress = useDifficultyProgressStore()

    expect(progress.unlockedLevels(12)).toEqual([1])
    expect(progress.isUnlocked(12, 2)).toBe(false)
    expect(progress.unlockNextLevel(12, 1)).toBe(2)
    expect(progress.unlockedLevels(12)).toEqual([1, 2])
    expect(progress.unlockNextLevel(12, 2)).toBe(3)
    expect(progress.unlockedLevels(12)).toEqual([1, 2, 3])
    expect(progress.unlockNextLevel(12, 3)).toBeNull()
  })

  it('keeps unlocked levels separate for each category', () => {
    const progress = useDifficultyProgressStore()

    progress.unlockNextLevel(12, 1)

    expect(progress.isUnlocked(12, 2)).toBe(true)
    expect(progress.isUnlocked(99, 2)).toBe(false)
  })

  it('does not announce an already unlocked level again', () => {
    const progress = useDifficultyProgressStore()

    expect(progress.unlockNextLevel(12, 1)).toBe(2)
    expect(progress.unlockNextLevel(12, 1)).toBeNull()
  })
})
