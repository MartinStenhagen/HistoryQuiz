async function readProgress(connection, userId) {
    const [statisticsRows] = await connection.execute(
        'SELECT * FROM v_user_statistics WHERE user_id = ?',
        [userId]
    );
    
    const row = statisticsRows[0];

    const [attempts] = await connection.execute(
    `
    SELECT is_correct
    FROM answer_attempts
    WHERE user_id = ?
    ORDER BY id
    `,
    [userId]
    );

    let currentStreak = 0;
    let bestStreak = 0;

    for (const attempt of attempts) {
      if (Number(attempt.is_correct) === 1) {
        currentStreak += 1;
        bestStreak = Math.max(bestStreak, currentStreak);
      } else {
        currentStreak = 0;
      }
    }
    
    const statistics = {
      totalAnswers: Number(row.total_answers),
      totalCorrect: Number(row.total_correct),
      uniqueCorrect: Number(row.unique_answers_correct),
      currentStreak,
      bestStreak,
    };
  
    const [challengeRows] = await connection.execute(
    `
    SELECT EXISTS (
      SELECT 1
      FROM challenge_runs AS r
      JOIN challenges AS c ON c.id = r.challenge_id
      WHERE r.user_id = ?
        AND c.code = ?
        AND r.status = 'passed'
    ) AS completed
    `,
    [userId, 'CAESAR_CHALLENGE']
    );  

  const progressByMetric = {
    total_answers: statistics.totalAnswers,
    total_correct: statistics.totalCorrect,
    unique_answers_correct: statistics.uniqueCorrect,
    correct_streak: statistics.bestStreak,
    caesar_challenge_completed: Number(challengeRows[0].completed),
  };

  const [definitions] = await connection.execute(
    `
    SELECT
      a.id,
      a.code,
      a.name,
      a.description,
      a.metric,
      a.target_value AS target,
      ua.awarded_at AS awardedAt
    FROM achievements AS a
    LEFT JOIN user_achievements AS ua
      ON ua.achievement_id = a.id
      AND ua.user_id = ?
    WHERE a.is_active = 1
    ORDER BY a.id
    `,
    [userId]
  );

  const achievements = definitions.map((achievement) => {
    const target = Number(achievement.target);
    const unlocked = achievement.awardedAt !== null;

    return {
      ...achievement,
      target,
      unlocked,
      progress: unlocked
        ? target
        : Math.min(
            progressByMetric[achievement.metric],
            target
          ),
    };
  });

  return { statistics, achievements };
}

async function awardAchievements(connection, userId) {
  const { achievements } = await readProgress(connection, userId);

  for (const achievement of achievements) {
    if (
      !achievement.unlocked &&
      achievement.progress >= achievement.target
    ) {
      await connection.execute(
        `
        INSERT INTO user_achievements (user_id, achievement_id)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE awarded_at = awarded_at
        `,
        [userId, achievement.id]
      );
    }
  }
}

module.exports = { readProgress, awardAchievements };
