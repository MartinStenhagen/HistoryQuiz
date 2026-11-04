const express = require('express');
const controller = require('../controllers/quizController');
const { requireAuth } = require('../middleware/requireAuth');

const router = express.Router();

router.get('/', controller.listPublished);
router.get('/:quizId/questions', controller.getQuestions);
router.post('/:quizId/questions/:questionId/check', controller.checkAnswer);
router.post('/:quizId/questions/:questionId/answer', requireAuth, controller.saveAnswer);

module.exports = router;
