const withUserTransaction = require('../database/withUserTransaction');
const questionService = require('./questionService');
const achievementService = require('./achievementService');

const CODE = 'CAESAR_CHALLENGE';

const fail = (status, message) =>
  Object.assign(new Error(message), { status });

async function readDefinition(connection) {
  const [rows] = await connection.execute(
    'SELECT * FROM challenges WHERE code = ?',
    [CODE]
  );

  if (!rows[0]) throw fail(404, 'Utmaningen finns inte.');
  return rows[0];
}

async function countQualification(connection, userId, challenge) {
  const [rows] = await connection.execute(
    `
    SELECT COUNT(DISTINCT a.question_id) AS correct_count
    FROM answer_attempts AS a
    JOIN questions AS q ON q.id = a.question_id
    WHERE a.user_id = ? AND a.is_correct = 1
      AND a.challenge_run_id IS NULL
      AND q.topic_id = ? AND q.difficulty = ?
      AND q.question_kind = 'regular'
    `,
    [userId, challenge.topic_id, challenge.required_difficulty]
  );

  return Number(rows[0].correct_count);
}

// Hämtar bara en omgång som tillhör användaren.
// Inga korrekta alternativ för obesvarade frågor skickas till klienten.
async function readRun(connection, userId, runId) {
  const [runs] = await connection.execute(
    `
    SELECT r.*, c.code, c.character_name, c.character_key
    FROM challenge_runs AS r
    JOIN challenges AS c ON c.id = r.challenge_id
    WHERE r.id = ? AND r.user_id = ?
    `,
    [runId, userId]
  );

  const run = runs[0];
  if (!run) throw fail(404, 'Omgången finns inte.');

  const [rows] = await connection.execute(
    `
    SELECT rq.question_id, q.question_text,
           o.id AS option_id, o.option_text,
           a.selected_option_id, a.is_correct
    FROM challenge_run_questions AS rq
    JOIN questions AS q ON q.id = rq.question_id
    JOIN answer_options AS o ON o.question_id = q.id
    LEFT JOIN answer_attempts AS a
      ON a.challenge_run_id = rq.challenge_run_id
      AND a.question_id = rq.question_id
    WHERE rq.challenge_run_id = ?
    ORDER BY rq.sort_order, o.sort_order
    `,
    [runId]
  );

  const byId = new Map();

  for (const row of rows) {
    if (!byId.has(row.question_id)) {
      byId.set(row.question_id, {
        id: row.question_id,
        questionText: row.question_text,
        options: [],
        selectedOptionId: row.selected_option_id,
        isCorrect: row.selected_option_id === null
          ? null
          : Number(row.is_correct) === 1,
      });
    }

    byId.get(row.question_id).options.push({
      id: row.option_id,
      text: row.option_text,
    });
  }

  const questions = [...byId.values()];
  const answered = questions.filter(q => q.selectedOptionId !== null);

  return {
    runId: run.id,
    challengeCode: run.code,
    characterName: run.character_name,
    characterKey: run.character_key,
    status: run.status,
    questionCount: Number(run.question_count),
    correctToPass: Number(run.correct_to_pass),
    answeredCount: answered.length,
    correctCount: answered.filter(q => q.isCorrect).length,
    nextQuestionId: run.status === 'in_progress'
      ? questions.find(q => q.selectedOptionId === null)?.id ?? null
      : null,
    questions,
  };
}

async function getCaesarStatus(userId) {
  return withUserTransaction(userId, async connection => {
    const challenge = await readDefinition(connection);
    const correct = await countQualification(connection, userId, challenge);
    const required = Number(challenge.required_unique_correct);
    const active = Number(challenge.is_active) === 1;

    return {
      userId,
      challenge: {
        code: challenge.code,
        topicId: challenge.topic_id,
        characterName: challenge.character_name,
        characterKey: challenge.character_key,
        requiredDifficulty: Number(challenge.required_difficulty),
        requiredCorrectAnswers: required,
        questionCount: Number(challenge.question_count),
        requiredCorrectToWin: Number(challenge.correct_to_pass),
        isActive: active,
      },
      qualification: {
        correctQuestions: correct,
        requiredCorrectAnswers: required,
        remaining: Math.max(0, required - correct),
        eligible: correct >= required,
      },
      available: active && correct >= required,
    };
  });
}

async function startRun({ userId, requestKey }) {
  return withUserTransaction(userId, async connection => {
    // Återanvänd omgången vid omsändning av samma startanrop.
    const [existing] = await connection.execute(
      `
      SELECT r.id, c.code
      FROM challenge_runs AS r
      JOIN challenges AS c ON c.id = r.challenge_id
      WHERE r.user_id = ? AND r.start_request_key = ?
      `,
      [userId, requestKey]
    );

    if (existing[0]) {
      if (existing[0].code !== CODE) {
        throw fail(409, 'Nyckeln används för en annan utmaning.');
      }
      return readRun(connection, userId, existing[0].id);
    }

    const challenge = await readDefinition(connection);

    if (Number(challenge.is_active) !== 1) {
      throw fail(409, 'Utmaningen är inte aktiverad.');
    }

    const correct = await countQualification(connection, userId, challenge);

    if (correct < Number(challenge.required_unique_correct)) {
      throw fail(403, 'Du behöver klara fler nivå 3-frågor först.');
    }

    const count = Number(challenge.question_count);

    if (!Number.isInteger(count) || count < 1 || count > 20) {
      throw fail(409, 'Utmaningen har ett ogiltigt antal frågor.');
    }

    // count är validerat ovan innan det används i LIMIT.
    const [questions] = await connection.execute(
      `
      SELECT cq.question_id
      FROM challenge_questions AS cq
      JOIN questions AS q ON q.id = cq.question_id
      JOIN answer_options AS o ON o.question_id = q.id
      WHERE cq.challenge_id = ? AND q.topic_id = ?
        AND q.question_kind = 'challenge' AND q.status = 'published'
      GROUP BY cq.question_id, cq.sort_order
      HAVING COUNT(*) = 4 AND SUM(o.is_correct) = 1
      ORDER BY cq.sort_order
      LIMIT ${count}
      `,
      [challenge.id, challenge.topic_id]
    );

    if (questions.length !== count) {
      throw fail(409, 'Utmaningen saknar tillräckligt många spelbara frågor.');
    }

    const [insert] = await connection.execute(
      `
      INSERT INTO challenge_runs (
        challenge_id, user_id, start_request_key,
        question_count, correct_to_pass
      ) VALUES (?, ?, ?, ?, ?)
      `,
      [challenge.id, userId, requestKey, count, challenge.correct_to_pass]
    );

    for (const [index, question] of questions.entries()) {
      await connection.execute(
        `
        INSERT INTO challenge_run_questions (
          challenge_run_id, question_id, sort_order
        ) VALUES (?, ?, ?)
        `,
        [insert.insertId, question.question_id, index + 1]
      );
    }

    return readRun(connection, userId, insert.insertId);
  });
}

async function saveAnswer({
  userId, runId, questionId, selectedOptionId, requestKey,
}) {
  return withUserTransaction(userId, async connection => {
    // Kontrollera omsändning före kontrollen av avslutad omgång.
    // Även det sista svaret måste kunna skickas om.
    const [existing] = await connection.execute(
      `
      SELECT challenge_run_id, question_id, selected_option_id, response_json
      FROM answer_attempts WHERE user_id = ? AND request_key = ?
      `,
      [userId, requestKey]
    );

    const previous = existing[0];

    if (previous) {
      if (
        previous.challenge_run_id !== runId ||
        previous.question_id !== questionId ||
        previous.selected_option_id !== selectedOptionId
      ) {
        throw fail(409, 'Nyckeln används redan för ett annat svar.');
      }

      if (previous.response_json === null) {
        throw fail(409, 'Det sparade försöket saknar återkoppling.');
      }

      return typeof previous.response_json === 'string'
        ? JSON.parse(previous.response_json)
        : previous.response_json;
    }

    const run = await readRun(connection, userId, runId);

    if (run.status !== 'in_progress') {
      throw fail(409, 'Omgången är redan avslutad.');
    }

    if (questionId !== run.nextQuestionId) {
      throw fail(409, 'Besvara nästa obesvarade fråga i omgången.');
    }

    let grading;

    try {
      grading = await questionService.answerQuestion(
        questionId, selectedOptionId, connection, 'challenge'
      );
    } catch (error) {
      if (error.code === 'INVALID_OPTION') error.status = 400;
      throw error;
    }

    if (!grading) {
      throw fail(409, 'Frågan är inte längre spelbar.');
    }

    const answeredCount = run.answeredCount + 1;
    const correctCount = run.correctCount + (grading.isCorrect ? 1 : 0);
    const finished = answeredCount === run.questionCount;

    const status = finished
      ? (correctCount >= run.correctToPass ? 'passed' : 'failed')
      : 'in_progress';

    const response = {
      ...grading,
      saved: true,
      run: {
        runId,
        status,
        answeredCount,
        correctCount,
        questionCount: run.questionCount,
        correctToPass: run.correctToPass,
        nextQuestionId: finished ? null : run.questions.find(
          q => q.selectedOptionId === null && q.id !== questionId
        )?.id ?? null,
      },
    };

    await connection.execute(
      `
      INSERT INTO answer_attempts (
        user_id, question_id, selected_option_id, is_correct,
        request_key, response_json, challenge_run_id
      ) VALUES (?, ?, ?, ?, ?, ?, ?)
      `,
      [
        userId, questionId, selectedOptionId, grading.isCorrect ? 1 : 0,
        requestKey, JSON.stringify(response), runId,
      ]
    );

    if (finished) {
      await connection.execute(
        `
        UPDATE challenge_runs
        SET status = ?, finished_at = UTC_TIMESTAMP(6)
        WHERE id = ? AND user_id = ?
        `,
        [status, runId, userId]
      );
    }

    await achievementService.awardAchievements(connection, userId);

    return response;
  });
}

async function getRun(userId, runId) {
  return withUserTransaction(
    userId,
    connection => readRun(connection, userId, runId)
  );
}

module.exports = {
  getCaesarStatus,
  startRun,
  saveAnswer,
  getRun,
};
