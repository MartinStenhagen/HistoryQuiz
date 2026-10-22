const authService = require('../services/authService');

module.exports = async function requireAuth(req, res, next) {
  const userId = req.session?.userId;

  if (!Number.isSafeInteger(userId) || userId < 1) {
    return res.status(401).json({
      error: 'Du behöver logga in.',
    });
  }

  const user = await authService.getSessionUser(userId);

  if (!user) {
    return res.status(401).json({
      error: 'Inloggningen är inte längre giltig.',
    });
  }

  req.user = user;
  next();
};
