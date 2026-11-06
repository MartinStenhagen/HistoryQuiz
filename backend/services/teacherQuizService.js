const database = require('../database/connection');

const fail = (status, message) =>
    Object.assign(new Error(message), { status });

function validateQuiz(input) {
    if (!input || typeof input !== 'object' || Array.isArray(input)) {
        throw fail(400, 'Quizet har ogiltigt format.');
    }

    const { title, description, topicId, difficulty, questions } = input;

    if (typeof title !== 'string' || !title.trim() || title.trim().length > 100) {
        throw fail(400, 'Quiznamnet måste vara mellan 1 och 100 tecken.');
    }

    if (
        description !== undefined &&
        description !== null &&
        (typeof description !== 'string' || description.trim().length > 500)
    ) {
        throw fail(400, 'Beskrivningen får vara högst 500 tecken.');
    }

    if (!Number.isSafeInteger(topicId) || topicId < 1) {
        throw fail(400, 'Välj ett giltigt ämne.');
    }

    if (!Number.isInteger(difficulty) || difficulty < 1 || difficulty > 3) {
        throw fail(400, 'Svårighetsgraden måste vara mellan 1 och 3.');
    }

    if (!Array.isArray(questions) || questions.length < 1 || questions.length > 20) {
        throw fail(400, 'Ett quiz måste innehålla mellan 1 och 20 frågor.');
    }

    const normalizedQuestions = questions.map((question, index) => {
        if (
            !question ||
            typeof question.questionText !== 'string' ||
            !question.questionText.trim() ||
            question.questionText.trim().length > 1000
        ) {
            throw fail(400, `Fråga ${index + 1} måste ha text på högst 1000 tecken.`);
        }

        if (
            typeof question.explanation !== 'string' ||
            !question.explanation.trim() ||
            question.explanation.trim().length > 2000
        ) {
            throw fail(400, `Fråga ${index + 1} måste ha en förklaring på högst 2000 tecken.`);
        }

        if (!Array.isArray(question.options) || question.options.length !== 4) {
            throw fail(400, `Fråga ${index + 1} måste ha exakt fyra svarsalternativ.`);
        }

        const options = question.options.map((option, optionIndex) => {
            if (
                !option ||
                typeof option.text !== 'string' ||
                !option.text.trim() ||
                option.text.trim().length > 500 ||
                typeof option.isCorrect !== 'boolean'
            ) {
                throw fail(400, `Svarsalternativ ${optionIndex + 1} i fråga ${index + 1} är ogiltigt.`);
            }

            return { text: option.text.trim(), isCorrect: option.isCorrect };
        });

        if (options.filter(option => option.isCorrect).length !== 1) {
            throw fail(400, `Fråga ${index + 1} måste ha exakt ett rätt svar.`);
        }

        return {
            questionText: question.questionText.trim(),
            explanation: question.explanation.trim(),
            options,
        };
    });

    return {
        title: title.trim(),
        description: description?.trim() || null,
        topicId,
        difficulty,
        questions: normalizedQuestions,
    };
}

async function insertQuestions(connection, quizId, topicId, difficulty, questions) {
    for (const question of questions) {
        const [result] = await connection.execute(
            `
            INSERT INTO questions (
                topic_id, question_text, explanation, difficulty,
                question_kind, quiz_id
            )
            VALUES (?, ?, ?, ?, 'regular', ?)
            `,
            [topicId, question.questionText, question.explanation, difficulty, quizId]
        );

        for (const [optionIndex, option] of question.options.entries()) {
            await connection.execute(
                `
                INSERT INTO answer_options (
                    question_id, option_text, sort_order, is_correct
                )
                VALUES (?, ?, ?, ?)
                `,
                [result.insertId, option.text, optionIndex + 1, option.isCorrect ? 1 : 0]
            );
        }
    }
}

async function getTeacherQuizzes(teacherId) {
    const [rows] = await database.execute(
        `
        SELECT
            q.id, q.title, q.description, q.topic_id AS topicId,
            t.name AS topicName, q.difficulty, q.status,
            q.created_at AS createdAt, q.updated_at AS updatedAt,
            COUNT(questions.id) AS questionCount
        FROM teacher_quizzes AS q
        JOIN topics AS t ON t.id = q.topic_id
        LEFT JOIN questions ON questions.quiz_id = q.id
        WHERE q.teacher_id = ?
        GROUP BY q.id
        ORDER BY q.updated_at DESC, q.id DESC
        `,
        [teacherId]
    );

    return rows.map(row => ({ ...row, questionCount: Number(row.questionCount) }));
}

async function getTopics() {
    const [rows] = await database.execute(
        'SELECT id, name, description FROM topics ORDER BY name'
    );
    return rows;
}

async function getTeacherQuiz(teacherId, quizId) {
    const [rows] = await database.execute(
        `
        SELECT id, title, description, topic_id AS topicId, difficulty, status
        FROM teacher_quizzes
        WHERE id = ? AND teacher_id = ? AND status = 'draft'
        `,
        [quizId, teacherId]
    );

    const quiz = rows[0];
    if (!quiz) throw fail(404, 'Utkastet finns inte.');

    const [questionRows] = await database.execute(
        `
        SELECT q.id, q.question_text AS questionText,
               q.explanation, o.option_text AS optionText,
               o.is_correct AS isCorrect, o.sort_order AS sortOrder
        FROM questions AS q
        JOIN answer_options AS o ON o.question_id = q.id
        WHERE q.quiz_id = ?
        ORDER BY q.id, o.sort_order
        `,
        [quizId]
    );

    const questions = new Map();
    for (const row of questionRows) {
        if (!questions.has(row.id)) {
            questions.set(row.id, {
                questionText: row.questionText,
                explanation: row.explanation,
                options: [],
            });
        }
        questions.get(row.id).options.push({
            text: row.optionText,
            isCorrect: Number(row.isCorrect) === 1,
        });
    }

    return { ...quiz, questions: [...questions.values()] };
}

async function createQuiz(teacherId, input) {
    const quiz = validateQuiz(input);
    const connection = await database.getConnection();

    try {
        await connection.beginTransaction();
        const [topics] = await connection.execute(
            'SELECT id FROM topics WHERE id = ?',
            [quiz.topicId]
        );
        if (!topics[0]) throw fail(400, 'Ämnet finns inte.');

        const [result] = await connection.execute(
            `
            INSERT INTO teacher_quizzes (
                teacher_id, title, description, topic_id, difficulty
            )
            VALUES (?, ?, ?, ?, ?)
            `,
            [teacherId, quiz.title, quiz.description, quiz.topicId, quiz.difficulty]
        );
        await insertQuestions(
            connection,
            result.insertId,
            quiz.topicId,
            quiz.difficulty,
            quiz.questions
        );
        await connection.commit();
        return { id: result.insertId, status: 'draft' };
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}

async function updateDraft(teacherId, quizId, input) {
    const quiz = validateQuiz(input);
    const connection = await database.getConnection();

    try {
        await connection.beginTransaction();
        const [quizzes] = await connection.execute(
            `
            SELECT id FROM teacher_quizzes
            WHERE id = ? AND teacher_id = ? AND status = 'draft'
            FOR UPDATE
            `,
            [quizId, teacherId]
        );
        if (!quizzes[0]) throw fail(404, 'Utkastet finns inte.');

        const [topics] = await connection.execute(
            'SELECT id FROM topics WHERE id = ?',
            [quiz.topicId]
        );
        if (!topics[0]) throw fail(400, 'Ämnet finns inte.');

        await connection.execute(
            `
            UPDATE teacher_quizzes
            SET title = ?, description = ?, topic_id = ?, difficulty = ?
            WHERE id = ? AND teacher_id = ?
            `,
            [quiz.title, quiz.description, quiz.topicId, quiz.difficulty, quizId, teacherId]
        );
        // Quizet är låst och kontrollerat som utkast ovan.
        await connection.execute(
            'DELETE FROM questions WHERE quiz_id = ?',
            [quizId]
        );
        await insertQuestions(
            connection,
            quizId,
            quiz.topicId,
            quiz.difficulty,
            quiz.questions
        );
        await connection.commit();
        return { id: quizId, status: 'draft' };
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}

async function publishQuiz(teacherId, quizId) {
    const connection = await database.getConnection();

    try {
        await connection.beginTransaction();
        const [quizzes] = await connection.execute(
            `
            SELECT id FROM teacher_quizzes
            WHERE id = ? AND teacher_id = ? AND status = 'draft'
            FOR UPDATE
            `,
            [quizId, teacherId]
        );
        if (!quizzes[0]) throw fail(404, 'Utkastet finns inte.');

        const [counts] = await connection.execute(
            `
            SELECT COUNT(*) AS question_count,
                   SUM(option_count <> 4 OR correct_count <> 1) AS invalid_count
            FROM (
                SELECT q.id, COUNT(o.id) AS option_count,
                       COALESCE(SUM(o.is_correct), 0) AS correct_count
                FROM questions AS q
                LEFT JOIN answer_options AS o ON o.question_id = q.id
                WHERE q.quiz_id = ?
                GROUP BY q.id
            ) AS question_checks
            `,
            [quizId]
        );

        if (
            Number(counts[0].question_count) < 1 ||
            Number(counts[0].invalid_count ?? 0) > 0
        ) {
            throw fail(400, 'Quizet behöver minst en fråga med fyra svar och exakt ett rätt svar.');
        }

        await connection.execute(
            `
            UPDATE teacher_quizzes
            SET status = 'published', published_at = CURRENT_TIMESTAMP(6)
            WHERE id = ? AND teacher_id = ?
            `,
            [quizId, teacherId]
        );
        await connection.commit();
        return { id: quizId, status: 'published' };
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}

async function archiveQuiz(teacherId, quizId) {
    const connection = await database.getConnection();

    try {
        await connection.beginTransaction();
        const [quizzes] = await connection.execute(
            `
            SELECT id FROM teacher_quizzes
            WHERE id = ? AND teacher_id = ? AND status = 'published'
            FOR UPDATE
            `,
            [quizId, teacherId]
        );
        if (!quizzes[0]) throw fail(404, 'Det publicerade quizet finns inte.');

        await connection.execute(
            `
            UPDATE teacher_quizzes
            SET status = 'archived'
            WHERE id = ? AND teacher_id = ?
            `,
            [quizId, teacherId]
        );
        await connection.commit();
        return { id: quizId, status: 'archived' };
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}

async function getPublishedQuizzes() {
    const [rows] = await database.execute(
        `
        SELECT q.id, q.title, q.description, q.difficulty,
               t.name AS topicName, COUNT(questions.id) AS questionCount
        FROM teacher_quizzes AS q
        JOIN topics AS t ON t.id = q.topic_id
        JOIN questions ON questions.quiz_id = q.id
        WHERE q.status = 'published'
        GROUP BY q.id
        ORDER BY q.published_at DESC, q.id DESC
        `
    );

    return rows.map(row => ({ ...row, questionCount: Number(row.questionCount) }));
}

async function getQuizQuestions(quizId) {
    const [rows] = await database.execute(
        `
        SELECT q.id AS questionId, q.question_text AS questionText,
               o.id AS optionId, o.option_text AS optionText
        FROM teacher_quizzes AS quiz
        JOIN questions AS q ON q.quiz_id = quiz.id
        JOIN answer_options AS o ON o.question_id = q.id
        WHERE quiz.id = ? AND quiz.status = 'published'
        ORDER BY q.id, o.sort_order
        `,
        [quizId]
    );

    const questions = new Map();
    for (const row of rows) {
        if (!questions.has(row.questionId)) {
            questions.set(row.questionId, {
                id: row.questionId,
                questionText: row.questionText,
                options: [],
            });
        }
        questions.get(row.questionId).options.push({
            id: row.optionId,
            text: row.optionText,
        });
    }

    return [...questions.values()];
}

module.exports = {
    getTeacherQuizzes,
    getTopics,
    getTeacherQuiz,
    createQuiz,
    updateDraft,
    publishQuiz,
    archiveQuiz,
    getPublishedQuizzes,
    getQuizQuestions,
};
