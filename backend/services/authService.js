import { argon2id } from "argon2";
import { use } from "react";

const usersDb = new Map();

function login(email, password){
    const user = usersDb.get(email);
    if(!user){
        return null; 
        console.log("no user with that email exists");
    }
}