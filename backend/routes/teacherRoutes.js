const express = require('express');
const router = express.Router();
const teacherController = require('../controllers/teacherController');

router.get('/api/getstudents', teacherController.getStudentsView);
router.get('/api/students/:id/results', teacherController.getStudentResult);


module.exports = router;