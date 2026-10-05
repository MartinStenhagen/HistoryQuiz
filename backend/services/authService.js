const argon2 = require('argon2');

const usersDb = new Map();

async function login(email, password){
    const user = usersDb.get(email);
    if(!user){
        return null; 
        console.log("no user with that email exists");
    }

    const isValid = await argon2.verify(user.passwordHash, password);
    if(!isValid){
        return null;
    }

    console.log(user.passwordHash);
    return {id: user.id, email: user.email};
}

async function registerUser(email, password){
    if(usersDb.has(email)){
        throw new Error('user already Exist');
    }

    const passwordHash = await argon2.hash(password, {
        type: argon2.argon2id,
    });

    const newUser = {
        id: Date.now(), email, passwordHash};
    

    usersDb.set(email, newUser);

    return {id: newUser.id, email: newUser.email}
}


module.exports = {
    registerUser,
    login
}