const authService = require('../services/authService');

async function requireAuth(req, res, next) {
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

  // Klientens förväntade konto är bara ett skydd vid kontobyte i en annan flik.
  // Ägaren till sparade svar hämtas alltid från den verifierade sessionen ovan.
  const expectedAccount = req.get('X-HistoryQuiz-Account');
  if (expectedAccount !== undefined && expectedAccount !== String(user.id)) {
    return res.status(409).json({
      code: 'ACCOUNT_CHANGED',
      error: 'Kontot har ändrats. Logga in på kontot där försöket påbörjades.',
    });
  }

  next();
};

async function requireAuthTeacher(req, res, next) {
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

  // Klientens förväntade konto är bara ett skydd vid kontobyte i en annan flik.
  // Ägaren till sparade svar hämtas alltid från den verifierade sessionen ovan.
  const expectedAccount = req.get('X-HistoryQuiz-Account');
  if (expectedAccount !== undefined && expectedAccount !== String(user.id)) {
    return res.status(409).json({
      code: 'ACCOUNT_CHANGED',
      error: 'Kontot har ändrats. Logga in på kontot där försöket påbörjades.',
    });
  }

  if (user.role === 'teacher') {
    return next(); 
  }
  return res.status(403).json({
      code: 'NOT_VALID_ROLE',
      error: 'kontots roll stämmer inte. Måste ha rätt behörighet som lärare'
    })
};

module.exports = {
  requireAuth,
  requireAuthTeacher
}