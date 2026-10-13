const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

router.post('/api/register', authController.registerUser);
router.get('/api/login', authController.loginAttempt);

module.exports = router;