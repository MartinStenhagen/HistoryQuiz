const mysql = require('mysql2/promise');
const { loadEnvFile } = require('node:process');
const path = require('node:path');

// Läs backend/.env även om Node startas från en annan arbetsmapp.
// Miljövariabler som redan är satta har företräde.
try {
    loadEnvFile(path.join(__dirname, '..', '.env'));
} catch (error) {
    if (error.code !== 'ENOENT') throw error;
}

for (const name of ['DB_USER', 'DB_NAME', 'DB_PASSWORD']) {
    if (process.env[name] === undefined || (name !== 'DB_PASSWORD' && !process.env[name])) {
        throw new Error(`${name} saknas. Konfigurera backend/.env enligt .env.example.`);
    }
}

const port = Number(process.env.DB_PORT || 3306);
if (!Number.isInteger(port) || port < 1 || port > 65535) {
    throw new Error('DB_PORT måste vara ett heltal mellan 1 och 65535.');
}

const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    port,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    charset: 'utf8mb4_0900_ai_ci',
    timezone: 'Z',
    waitForConnections: true,
    connectionLimit: 10,
    multipleStatements: false,
});

async function getConnection() {
    const connection = await pool.getConnection();
    try {
        // timezone: 'Z' styr datum i Node; sessionen styr MySQLs CURRENT_TIMESTAMP.
        await connection.query("SET SESSION time_zone = '+00:00'");
        return connection;
    } catch (error) {
        connection.destroy();
        throw error;
    }
}

async function execute(sql, parameters = []) {
    const connection = await getConnection();
    try {
        return await connection.execute(sql, parameters);
    } finally {
        connection.release();
    }
}

module.exports = { execute, getConnection, end: () => pool.end() };
