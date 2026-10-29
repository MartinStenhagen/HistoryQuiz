const database = require('../database/connection');

const CAESAR_CHALLENGE = Object.freeze({
  code: 'CAESAR_CHALLENGE',
  characterName: 'Julius Caesar',
  topicName: 'Romarriket',
  requiredDifficulty: 3,
  requiredCorrectAnswers: 5,
  questionCount: 5,
  requiredCorrectToWin: 4,
  achievementCode: 'HISTORICAL_CHALLENGER',
});

async function getCaesarStatus(userId, executor = database) {
  if (!Number.isSafeInteger(userId) || userId < 1) {
    throw Object.assign(new Error('Ogiltigt användar-ID.'), {
      status: 400,
    });
  }

  const challenge = CAESAR_CHALLENGE;

  const [rows] = await executor.execute(
    `
    SELECT
      t.id AS topicId,
      COUNT(DISTINCT a.question_id) AS correctQuestions
    FROM topics AS t
    LEFT JOIN questions AS q
      ON q.topic_id = t.id
      AND q.difficulty = ?
    LEFT JOIN answer_attempts AS a
      ON a.question_id = q.id
      AND a.user_id = ?
      AND a.is_correct = 1
    WHERE t.name = ?
    GROUP BY t.id
    `,
    [
      challenge.requiredDifficulty,
      userId,
      challenge.topicName,
    ]
  );

  const progress = rows[0];

  if (!progress) {
    throw Object.assign(
      new Error('Utmaningens kategori finns inte ännu.'),
      { status: 404 }
    );
  }

  const correctQuestions = Number(progress.correctQuestions);
  const required = challenge.requiredCorrectAnswers;

  return {
    userId,
    challenge: {
      ...challenge,
      topicId: progress.topicId,
    },
    qualification: {
      correctQuestions,
      requiredCorrectAnswers: required,
      remaining: Math.max(0, required - correctQuestions),
      eligible: correctQuestions >= required,
    },
  };
}

module.exports = { getCaesarStatus };
