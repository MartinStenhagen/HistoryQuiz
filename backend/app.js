const express = require('express');
const {
  sessionMiddleware,
  sessionStore,
} = require('./middleware/session');

const app = express();
if (!process.env.APP_ORIGIN) {
  throw new Error('APP_ORIGIN saknas. Ange frontendens adress i backend/.env.');
}
const appOrigin = new URL(process.env.APP_ORIGIN).origin;

app.use(express.json());

app.use('/api', (req, res, next) => {
  res.set('Cache-Control', 'no-store');

  if (['GET', 'HEAD', 'OPTIONS'].includes(req.method)) {
    return next();
  }

  if (
    req.get('Origin') !== appOrigin ||
    req.get('X-HistoryQuiz-Request') !== '1'
  ) {
    return res.status(403).json({
      error: 'Anropet kommer inte från den tillåtna klienten.',
    });
  }

  if (!req.is('application/json')) {
    return res.status(415).json({
      error: 'Anropet måste innehålla JSON.',
    });
  }

  next();
});

app.use(sessionMiddleware);

const authRoutes = require('./routes/authRoutes');
const teacherRoutes = require('./routes/teacherRoutes');

const questionRoutes = require('./routes/questionRoutes');
app.use('/api/questions', questionRoutes);

const topicRoutes = require('./routes/topicRoutes');
app.use('/api/topics', topicRoutes);

app.use(authRoutes);
app.use(teacherRoutes);

const achievementRoutes = require('./routes/achievementRoutes');
app.use('/api/me/achievements', achievementRoutes);

app.use('/api', (req, res) => {
  res.status(404).json({ error: 'API-adressen finns inte.' });
});

app.use((error, req, res, next) => {
  if (res.headersSent) {
    return next(error);
  }

  const status =
    Number.isInteger(error.status) &&
    error.status >= 400 &&
    error.status < 500
      ? error.status
      : 500;

  if (status === 500) {
    console.error(error);
  }

  res.status(status).json({
    error:
      status === 500
        ? 'Ett serverfel inträffade. Försök igen.'
        : error.message,
  });
});

if (require.main === module) {
  sessionStore.onReady()
    .then(() => {
      const port = Number(process.env.PORT || 3000);
      app.listen(port, () => console.log(`HistoryQuiz API lyssnar på port ${port}.`));
    })
    .catch(async (error) => {
      console.error('Kunde inte starta sessionslagringen:', error);
      await sessionStore.close();
      await require('./database/connection').end();
      process.exitCode = 1;
    });
}

module.exports = app;
