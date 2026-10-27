const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

router.post('/api/register', authController.registerUser);
router.post('/api/login', authController.loginAttempt);

const {requireAuth} = require('../middleware/requireAuth');

router.get('/api/me', requireAuth, authController.me);
router.post('/api/logout', authController.logout);

module.exports = router;