const argon2 = require('argon2');
const connectionMySQL = require('../database/connection');

async function login(username, password) {
  const user = await getUser(username);

  if (!user || Number(user.is_active) !== 1) {
    return null;
  }

  const validPassword = await argon2.verify(
    user.password_hash,
    password
  );

  if (!validPassword) {
    return null;
  }

  return getSessionUser(user.id);
}

async function getUser(userN) {
    const sql = 'SELECT * FROM users WHERE username = ?';
    const [rows] = await connectionMySQL.execute(sql, [userN]);
    return rows.length > 0 ? rows[0] : null;
}

async function registerUser(userN, displayN, userPass) {
    // Slå upp standardrollen via dess kod i stället för att anta ett visst ID.
    const [roles] = await connectionMySQL.execute(
        'SELECT id FROM roles WHERE code = ?', ['student']
    );

    if (roles.length === 0) {
        throw new Error('Standardrollen student saknas i databasen.');
    }

    const userRole = roles[0].id;
    const passwordHash = await argon2.hash(userPass, {
        type: argon2.argon2id,
    });

    const sql = 'INSERT INTO users (role_id, username, display_name, password_hash) VALUES (?, ?, ?, ?)';

    const [result] = await connectionMySQL.execute(sql, [userRole, userN, displayN, passwordHash]);

    return {
        id: result.insertId,
        role_id: userRole,
        username: userN,
        display_name: displayN
    };
}

async function getSessionUser(userId) {
  const [rows] = await connectionMySQL.execute(
    `
    SELECT
      u.id,
      u.username,
      u.display_name AS displayName,
      r.code AS role
    FROM users AS u
    JOIN roles AS r ON r.id = u.role_id
    WHERE u.id = ?
      AND u.is_active = 1
    `,
    [userId]
  );

  return rows[0] ?? null;
}

module.exports = {
    registerUser,
    login,
    getSessionUser
}
