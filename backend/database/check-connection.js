const database = require('./connection');

async function main() {
    try {
        const [rows] = await database.execute(`
            SELECT VERSION() AS mysql_version,
                   DATABASE() AS database_name,
                   @@default_storage_engine AS default_engine,
                   @@session.time_zone AS session_time_zone,
                   @@character_set_connection AS character_set,
                   @@collation_connection AS collation
        `);
        console.table(rows);
    } finally {
        await database.end();
    }
}

main().catch((error) => {
    console.error('Databaskontrollen misslyckades:', error.code || error.message);
    process.exitCode = 1;
});
