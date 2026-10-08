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
async function registerUser(userN, userPass){
    const passwordHash = await argon2.hash(userPass, {
        type: argon2.argon2id,
    });

    return new Promise((resolve, reject) => {
        const sql = 'INSERT INTO users (username, Password_hash) VALUES (?,?)';
        connectionMySQL.execute(sql, [userN], [passwordHash], (err, result) =>{
            if (err) return reject(err);
            resolve({ id: result.insertId, username, email });
        });
    });
}


module.exports = {
    registerUser,
    login
}