// Exempelstatus för att bygga och prova sidan innan konto- och utmärkelse-API:t finns.
export const achievementDefinitions = [
  {
    code: 'FIRST_ANSWER',
    name: 'Första steget',
    description: 'Svara på din första fråga.',
    icon: '🌱',
    target: 1,
  },
  {
    code: 'TEN_CORRECT',
    name: 'Historiekännaren',
    description: 'Svara rätt tio gånger totalt.',
    icon: '🧠',
    target: 10,
  },
  {
    code: 'TEN_UNIQUE_CORRECT',
    name: 'Historieutforskaren',
    description: 'Svara rätt på tio olika frågor.',
    icon: '🧭',
    target: 10,
  },
  {
    code: 'THREE_IN_A_ROW',
    name: 'Tre i rad',
    description: 'Svara rätt tre gånger i följd.',
    icon: '🔥',
    target: 3,
  },
]
