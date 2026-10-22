const express = require('express');
const router = express.Router();
const questionController = require('../controllers/questionController');

router.get('/', questionController.getQuestions);

const requireAuth = require('../middleware/requireAuth');

router.get('/', questionController.getQuestions);

// Befintlig rättning utan att spara.
router.post('/:id/check', questionController.answerQuestion);

// Ny rättning med kontokoppling.
router.post('/:id/answer', requireAuth, questionController.saveAnswer);

const withUserTransaction = require('../database/withUserTransaction');
const achievementService = require('../services/achievementService');

exports.getMyAchievements = async (req, res) => {
  const progress = await withUserTransaction(
    req.user.id,
    (connection) =>
      achievementService.readProgress(connection, req.user.id)
  );

  res.json({
    userId: req.user.id,
    ...progress,
  });
};

router.get(
  '/api/me/achievements',
  requireAuth,
  achievementController.getMyAchievements
);

module.exports = router;
