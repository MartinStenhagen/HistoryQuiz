const express = require('express');
const router = express.Router();
const teacherController = require('../controllers/teacherController');
const {requireAuthTeacher} = require('../middleware/requireAuth');

router.get('/api/getstudents', requireAuthTeacher, teacherController.getStudentsView);
router.get('/api/students/:id/results', requireAuthTeacher, teacherController.getStudentResult);


module.exports = router;