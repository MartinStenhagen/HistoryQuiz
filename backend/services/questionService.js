const database = require('../database/connection');

async function getQuestions(limit, topicId = null) {
    // Kontrollen skyddar även om servicen senare anropas från annan kod.
    if (!Number.isInteger(limit) || limit < 1 || limit > 20) {
        throw new Error('Ogiltigt antal frågor.');
    }

    if (topicId !== null && (!Number.isSafeInteger(topicId) || topicId < 1)) {
        throw new Error('Ogiltigt ämnes-ID.');
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
                AND (? IS NULL OR questions.topic_id = ?)
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

    const [rows] = await database.execute(sql, ['published', topicId, topicId]);

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

async function answerQuestion(questionId, selectedOptionId, executor = database) {
    const sql = `
        SELECT
            q.explanation,
            o.id AS optionId,
            o.is_correct AS isCorrect
        FROM questions AS q
        JOIN answer_options AS o
            ON o.question_id = q.id
        WHERE q.id = ?
            AND q.status = ?
        ORDER BY o.sort_order
    `;

    const [rows] = await executor.execute(sql, [questionId, 'published']);

    // Samma krav som GET: fyra alternativ och exakt ett rätt.
    const correctOptions = rows.filter(
        (option) => Number(option.isCorrect) === 1
    );

    if (rows.length !== 4 || correctOptions.length !== 1) {
        return null;
    }

    // Sök bara bland alternativ som tillhör denna fråga.
    const selectedOption = rows.find(
        (option) => option.optionId === selectedOptionId
    );

    if (!selectedOption) {
        const error = new Error(
            'Det valda alternativet tillhör inte frågan.'
        );

        error.code = 'INVALID_OPTION';
        throw error;
    }

    const correctOption = correctOptions[0];

    return {
        isCorrect: selectedOption.optionId === correctOption.optionId,
        correctOptionId: correctOption.optionId,
        explanation: rows[0].explanation,
    };
}

module.exports = { getQuestions, answerQuestion };
