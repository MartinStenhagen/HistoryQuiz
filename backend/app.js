const express = require('express');
const cors = require('cors');

const app = express();
const port = 3000;

// Parse JSON bodies
app.use(express.json());

// For parsing application/x-www-form-urlencoded
app.use(express.urlencoded({ extended: true }));

app.use(cors());
app.use(express.static('public'));

const express = require('express');

const {
  sessionMiddleware,
  sessionStore,
} = require('./middleware/session');

const app = express();
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

const questionRoutes = require('./routes/questionRoutes');
app.use('/api/questions', questionRoutes);

const topicRoutes = require('./routes/topicRoutes');
app.use('/api/topics', topicRoutes);

app.use(authRoutes);

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

sessionStore.onReady()
  .then(() => {
    app.listen(3000);
  })
  .catch((error) => {
    console.error('Kunde inte starta sessionslagringen:', error);
    process.exitCode = 1;
  });

app.listen(port, () => console.log(`Example app listening on port ${port}!`));
