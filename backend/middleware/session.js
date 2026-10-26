const database = require('../database/connection');
const session = require('express-session');
const MySQLStore = require('express-mysql-session')(session);

const secret = process.env.SESSION_SECRET;

if (!secret || secret.length < 32) {
  throw new Error('SESSION_SECRET saknas eller är för kort.');
}

const cookieName = 'historyquiz.sid';

const cookieOptions = {
  httpOnly: true,
  secure: process.env.NODE_ENV === 'production',
  sameSite: 'lax',
  path: '/',
};

const sessionStore = new MySQLStore(
  { createDatabaseTable: false },
  database.pool
);

const sessionMiddleware = session({
  name: cookieName,
  secret,
  store: sessionStore,
  resave: false,
  saveUninitialized: false,
  rolling: true,
  cookie: {
    ...cookieOptions,
    maxAge: 24 * 60 * 60 * 1000,
  },
});

module.exports = {
  sessionMiddleware,
  sessionStore,
  cookieName,
  cookieOptions,
};
