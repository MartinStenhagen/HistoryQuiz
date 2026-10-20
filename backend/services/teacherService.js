const connectionMySQL = require('../database/connection');

async function getStudents() {
    const sql = 'SELECT id, username, display_name FROM users WHERE role_id = 1';
    const [rows] = await connectionMySQL.execute(sql);
    return rows;
}

async function getStudentResults(studentId) {
    const sql = 'SELECT users.username, v_user_statistics.total_answers, v_user_statistics.total_correct, v_user_statistics.total_wrong FROM users INNER JOIN v_user_statistics ON users.id = v_user_statistics.user_id WHERE users.id = ?';
    const [rows] = await connectionMySQL.execute(sql, [studentId]);
    return rows.length > 0 ? rows[0] : null;
}

module.exports= {
    getStudents,
    getStudentResults
}