const quizService = require('../services/teacherQuizService');

function quizId(req) {
    if (!/^[1-9]\d*$/.test(req.params.quizId)) {
        throw Object.assign(new Error('Quiz-ID måste vara ett positivt heltal.'), {
            status: 400,
        });
    }

    const id = Number(req.params.quizId);
    if (!Number.isSafeInteger(id)) {
        throw Object.assign(new Error('Quiz-ID måste vara ett positivt heltal.'), {
            status: 400,
        });
    }
    return id;
}

exports.list = async (req, res) => {
    res.json({ quizzes: await quizService.getTeacherQuizzes(req.user.id) });
};

exports.topics = async (req, res) => {
    res.json({ topics: await quizService.getTopics() });
};

exports.getDraft = async (req, res) => {
    res.json(await quizService.getTeacherQuiz(req.user.id, quizId(req)));
};

exports.create = async (req, res) => {
    res.status(201).json(await quizService.createQuiz(req.user.id, req.body));
};

exports.updateDraft = async (req, res) => {
    res.json(await quizService.updateDraft(req.user.id, quizId(req), req.body));
};

exports.publish = async (req, res) => {
    res.json(await quizService.publishQuiz(req.user.id, quizId(req)));
};

exports.archive = async (req, res) => {
    res.json(await quizService.archiveQuiz(req.user.id, quizId(req)));
};
