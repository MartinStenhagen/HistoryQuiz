const argon2 = require('argon2');
const connectionMySQL = require('../database/connection');

async function login(userName, userPass) {
    const user = await getUser(userName);
    if(!user){
        return null;
    }
    
    const isValid = await argon2.verify(user.password_hash, userPass);
    if (!isValid){
        return null;
    }

    const{password_hash, ...safeUser} = user;
    return safeUser;
}

async function getUser(userN) {
    const sql = 'SELECT * FROM users WHERE username = ?';
    const [rows] = await connectionMySQL.execute(sql, [userN]);
    return rows.length > 0 ? rows[0] : null;
}

//ska utarbetas mer för registrerandet av användare
async function registerUser(role, userN, displayN, userPass){
    const passwordHash = await argon2.hash(userPass, {
        type: argon2.argon2id,
    });

    let userRole = null;

    if (role === 'student'){
        userRole = 1;
    } else if(role === 'teacher'){
        userRole = 2;
    } else if(role === 'admin'){
        userRole = 3;
    } else{
        throw new Error('not a valid role');
    }

    const sql = 'INSERT INTO users (role_id, username, display_name, Password_hash) VALUES (?, ?, ?, ?)';
    
    const [result] = await connectionMySQL.execute(sql, [userRole, userN, displayN, passwordHash]);

    return { 
        id: result.insertId, 
        role_id: userRole, 
        username: userN, 
        display_name: displayN 
    };
}


module.exports = {
    registerUser,
    login
}