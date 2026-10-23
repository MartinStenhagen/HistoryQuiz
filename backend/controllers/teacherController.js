const teacherService = require('../services/teacherService');

exports.getStudentsView = async (req, res) => {
    try {
        const students = await teacherService.getStudents();
        return res.status(200).json(students);
    } catch (error) { 
        return res.status(500).json({ error: 'Internal server error' });
    }
}

exports.getStudentResult = (async (req, res) => {
    try{
        const userid = req.params.id;
        const student = await teacherService.getStudentResults(userid);
        if(!student){
            return res.status(404).json({ error: 'no user with that id found'});
        }
        return res.status(200).json(student);
    } catch (error){
        console.error(error);
        return res.status(500).json({ error: 'Internal server error' });
    }
})