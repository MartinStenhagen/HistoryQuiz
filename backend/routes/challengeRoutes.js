const express = require('express');
const requireAuth = require('../middleware/requireAuth');
const challangeController = require('../controllers/challangeController');

const router = express.Router();

router.get('/caesar/status', requireAuth, challangeController.getCaesarStatus);

module.exports = router;