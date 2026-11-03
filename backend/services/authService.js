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

async function registerUser(userId, userR, userN, displayN, userPass) {
    // Slå upp standardrollen via dess kod i stället för att anta ett visst ID.
    const [roles] = await connectionMySQL.execute(
        'SELECT * FROM roles'
    );

    const roleMap = {};
    roles.forEach(r => {
        if (r.code) {
            roleMap[r.code.toLowerCase()] = r.id;
        }
    });
    
    if (!roleMap['student']) {
        throw new Error('Standardrollen student saknas i databasen.');
    }

    let targetRoleId;

    if (!userId) {
        targetRoleId = roleMap['student'];
    } else {
        const creator = await getSessionUser(userId);

        const isPrivileged = creator && (
            creator.role === 'teacher' || 
            creator.role === 'admin' || 
            creator.id === 2 || 
            creator.id === 3
        );

        if (isPrivileged) {
            if (userR && Object.values(roleMap).includes(Number(userR))) {
                targetRoleId = Number(userR);
            } else {
                targetRoleId = roleMap['student'];
            }
        } else {
            targetRoleId = roleMap['student'];
        }
    }

    const passwordHash = await argon2.hash(userPass, {
        type: argon2.argon2id,
    });

    const sql = 'INSERT INTO users (role_id, username, display_name, password_hash) VALUES (?, ?, ?, ?)';

    const [result] = await connectionMySQL.execute(sql, [targetRoleId, userN, displayN, passwordHash]);

    return {
        id: result.insertId,
        role_id: targetRoleId,
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
