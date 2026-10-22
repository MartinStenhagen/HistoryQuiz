const withUserTransaction = require('../database/withUserTransaction');
const questionService = require('./questionService');
const achievementService = require('./achievementService');

const fail = (status, message) =>
  Object.assign(new Error(message), { status });

async function saveAnswer({
  userId,
  questionId,
  selectedOptionId,
  requestKey,
}) {
  return withUserTransaction(userId, async (connection) => {
    const [existingRows] = await connection.execute(
      `
      SELECT question_id, selected_option_id, response_json
      FROM answer_attempts
      WHERE user_id = ? AND request_key = ?
      `,
      [userId, requestKey]
    );

    const existing = existingRows[0];

    if (existing) {
      if (
        existing.question_id !== questionId ||
        existing.selected_option_id !== selectedOptionId
      ) {
        throw fail(409, 'Nyckeln används redan för ett annat svar.');
      }

      if (existing.response_json === null) {
        throw fail(
          409,
          'Det äldre försöket saknar sparad återkoppling.'
        );
      }

      return typeof existing.response_json === 'string'
        ? JSON.parse(existing.response_json)
        : existing.response_json;
    }

    const grading = await questionService.answerQuestion(
      questionId,
      selectedOptionId,
      connection
    );

    if (!grading) {
      throw fail(404, 'Frågan finns inte eller är inte spelbar.');
    }

    const response = {
      ...grading,
      saved: true,
    };

    await connection.execute(
      `
      INSERT INTO answer_attempts (
        user_id,
        question_id,
        selected_option_id,
        is_correct,
        request_key,
        response_json
      )
      VALUES (?, ?, ?, ?, ?, ?)
      `,
      [
        userId,
        questionId,
        selectedOptionId,
        grading.isCorrect ? 1 : 0,
        requestKey,
        JSON.stringify(response),
      ]
    );

    await achievementService.awardAchievements(connection, userId);

    return response;
  });
}

module.exports = { saveAnswer };
