const express = require('express');
const { requireAuthTeacher } = require('../middleware/requireAuth');
const controller = require('../controllers/teacherQuizController');

const router = express.Router();
router.use(requireAuthTeacher);

router.get('/topics', controller.topics);
router.get('/', controller.list);
router.get('/:quizId', controller.getDraft);
router.post('/', controller.create);
router.put('/:quizId', controller.updateDraft);
router.post('/:quizId/publish', controller.publish);
router.post('/:quizId/archive', controller.archive);

module.exports = router;
