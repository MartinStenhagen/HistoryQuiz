const express = require('express');
const requireAuth = require('../middleware/requireAuth');
const challengeController = require('../controllers/challengeController');

const router = express.Router();
router.use(requireAuth);

router.get('/caesar/status', controller.getCaesarStatus);
router.post('/caesar/runs', controller.startRun);
router.get('/runs/:runId', controller.getRun);
router.post('/runs/:runId/answers', controller.saveAnswer);

module.exports = router;
