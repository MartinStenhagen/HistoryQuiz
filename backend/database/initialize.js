const mysql = require('mysql2/promise');
const { readFile } = require('node:fs/promises');
const { loadEnvFile } = require('node:process');
const path = require('node:path');

try {
    loadEnvFile(path.join(__dirname, '../.env'));
} catch (error) {
    if (error.code !== 'ENOENT') throw error;
}

async function initializeDatabase({ seed = false } = {}) {
    const databaseName = process.env.DB_NAME;

    if (!databaseName) {
        throw new Error('DB_NAME saknas i backend/.env.');
    }

    // Anslut först till MySQL utan att välja databas.
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST || 'localhost',
        port: Number(process.env.DB_PORT || 3306),
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        charset: 'utf8mb4_0900_ai_ci',
        timezone: 'Z',

        // Behövs för att köra våra egna SQL-filer.
        multipleStatements: true,
    });

    try {
        const databaseIdentifier = mysql.escapeId(databaseName, true);

        await connection.query(`
            CREATE DATABASE IF NOT EXISTS ${databaseIdentifier}
            CHARACTER SET utf8mb4
            COLLATE utf8mb4_0900_ai_ci
        `);

        await connection.query(`USE ${databaseIdentifier}`);

        const schemaSql = await readFile(
            path.join(__dirname, 'schema.sql'),
            'utf8'
        );

        await connection.query(schemaSql);

        if (seed) {
            const seedSql = await readFile(
                path.join(__dirname, 'seed.sql'),
                'utf8'
            );

            await connection.beginTransaction();

            try {
                await connection.query(seedSql);
                await connection.commit();
            } catch (error) {
                await connection.rollback();
                throw error;
            }
        }
    } finally {
        await connection.end();
    }
}

// Körs när filen startas direkt med npm run db:init.
if (require.main === module) {
    initializeDatabase({ seed: true })
        .then(() => {
            console.log('Databas, schema och seed är klara.');
        })
        .catch((error) => {
            console.error('Databasinitieringen misslyckades:', error.message);
            process.exitCode = 1;
        });
}

module.exports = { initializeDatabase };
