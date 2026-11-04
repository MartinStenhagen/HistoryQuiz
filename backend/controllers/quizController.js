const quizService = require('../services/teacherQuizService');
const questionService = require('../services/questionService');
const answerAttemptService = require('../services/answerAttemptService');

function positiveId(value, label) {
    if (!/^[1-9]\d*$/.test(value)) {
        throw Object.assign(new Error(`${label} måste vara ett positivt heltal.`), {
            status: 400,
        });
    }

    const id = Number(value);
    if (!Number.isSafeInteger(id)) {
        throw Object.assign(new Error(`${label} måste vara ett positivt heltal.`), {
            status: 400,
        });
    }
    return id;
}

function requestKey(value) {
    const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    if (typeof value !== 'string' || !uuid.test(value)) {
        throw Object.assign(new Error('requestKey måste vara ett UUID v4.'), {
            status: 400,
        });
    }
    return value.toLowerCase();
}

exports.listPublished = async (req, res) => {
    res.json({ quizzes: await quizService.getPublishedQuizzes() });
};

exports.getQuestions = async (req, res) => {
    const id = positiveId(req.params.quizId, 'Quiz-ID');
    const questions = await quizService.getQuizQuestions(id);
    if (questions.length === 0) {
        return res.status(404).json({ error: 'Quizet finns inte eller är inte publicerat.' });
    }
    res.json({ questions });
};

exports.checkAnswer = async (req, res) => {
    const quizId = positiveId(req.params.quizId, 'Quiz-ID');
    const questionId = positiveId(req.params.questionId, 'Fråge-ID');
    const selectedOptionId = req.body?.selectedOptionId;
    if (!Number.isSafeInteger(selectedOptionId) || selectedOptionId < 1) {
        throw Object.assign(new Error('selectedOptionId måste vara ett positivt heltal.'), {
            status: 400,
        });
    }

    const result = await questionService.answerQuestion(
        questionId,
        selectedOptionId,
        undefined,
        'regular',
        quizId
    );
    if (!result) {
        return res.status(404).json({ error: 'Frågan finns inte eller är inte spelbar.' });
    }
    res.json(result);
};

exports.saveAnswer = async (req, res) => {
    const quizId = positiveId(req.params.quizId, 'Quiz-ID');
    const questionId = positiveId(req.params.questionId, 'Fråge-ID');
    const selectedOptionId = req.body?.selectedOptionId;
    if (!Number.isSafeInteger(selectedOptionId) || selectedOptionId < 1) {
        throw Object.assign(new Error('selectedOptionId måste vara ett positivt heltal.'), {
            status: 400,
        });
    }

    const result = await answerAttemptService.saveAnswer({
        userId: req.user.id,
        questionId,
        selectedOptionId,
        requestKey: requestKey(req.body?.requestKey),
        quizId,
    });
    res.json(result);
};
