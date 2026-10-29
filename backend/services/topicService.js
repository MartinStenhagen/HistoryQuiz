const database = require('../database/connection');

async function getTopics() {
    const sql = `
        SELECT
            t.id,
            t.name,
            t.description
        FROM topics AS t
        WHERE EXISTS (
            SELECT q.id
            FROM questions AS q
            JOIN answer_options AS o
                ON o.question_id = q.id
            WHERE q.topic_id = t.id
                AND q.status = ?
                AND q.question_kind = 'regular'
            GROUP BY q.id
            HAVING COUNT(*) = 4
                AND SUM(o.is_correct) = 1
        )
        ORDER BY t.name
    `;

    const [rows] = await database.execute(sql, ['published']);

    return rows;
}

module.exports = { getTopics };
