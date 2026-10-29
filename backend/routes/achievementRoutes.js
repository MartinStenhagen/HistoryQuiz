const router = require('express').Router();
const {requireAuth} = require('../middleware/requireAuth');
const achievementController = require('../controllers/achievementController');

router.get('/', requireAuth, achievementController.getMyAchievements);

module.exports = router;
