const express = require('express');
const { requireAuth } = require('../middleware/requireAuth');
const challengeController = require('../controllers/challengeController');

const router = express.Router();
router.use(requireAuth);

router.get('/caesar/status', challengeController.getCaesarStatus);
router.post('/caesar/runs', challengeController.startRun);
router.get('/runs/:runId', challengeController.getRun);
router.post('/runs/:runId/answers', challengeController.saveAnswer);

module.exports = router;
