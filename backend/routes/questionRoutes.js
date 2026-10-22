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

module.exports = router;
