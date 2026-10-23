const database = require('./connection');

module.exports = async function withUserTransaction(userId, work) {
  const connection = await database.getConnection();
  let usable = true;

  try {
    await connection.beginTransaction();

    const [users] = await connection.execute(
      'SELECT is_active FROM users WHERE id = ? FOR UPDATE',
      [userId]
    );

    if (!users[0] || Number(users[0].is_active) !== 1) {
      throw Object.assign(
        new Error('Kontot är inte tillgängligt.'),
        { status: 401 }
      );
    }

    const result = await work(connection);

    await connection.commit();
    return result;
  } catch (error) {
    try {
      await connection.rollback();
    } catch {
      // En anslutning med okänt transaktionstillstånd ska inte återanvändas.
      usable = false;
      connection.destroy();
    }
    throw error;
  } finally {
    if (usable) connection.release();
  }
};
