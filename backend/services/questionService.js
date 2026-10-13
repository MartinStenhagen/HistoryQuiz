const database = require('../database/connection');

async function getQuestions(limit) {
    // Kontrollen skyddar även om servicen senare anropas från annan kod.
    if (!Number.isInteger(limit) || limit < 1 || limit > 20) {
        throw new Error('Ogiltigt antal frågor.');
    }

    const sql = `
        SELECT
            q.id AS questionId,
            q.question_text AS questionText,
            o.id AS optionId,
            o.option_text AS optionText
        FROM (
            SELECT
                questions.id,
                questions.question_text
            FROM questions
            JOIN answer_options
                ON answer_options.question_id = questions.id
            WHERE questions.status = ?
            GROUP BY questions.id, questions.question_text
            HAVING COUNT(*) = 4
                AND SUM(answer_options.is_correct) = 1
            ORDER BY questions.id
            LIMIT ${limit}
        ) AS q
        JOIN answer_options AS o
            ON o.question_id = q.id
        ORDER BY q.id, o.sort_order
    `;

    const [rows] = await database.execute(sql, ['published']);

    // SQL ger en rad per alternativ.
    // Alternativen samlas under respektive fråga.
    const questionsById = new Map();

    for (const row of rows) {
        if (!questionsById.has(row.questionId)) {
            questionsById.set(row.questionId, {
                id: row.questionId,
                questionText: row.questionText,
                options: [],
            });
        }

        const question = questionsById.get(row.questionId);

        question.options.push({
            id: row.optionId,
            text: row.optionText,
        });
    }

    return Array.from(questionsById.values());
}

module.exports = { getQuestions };