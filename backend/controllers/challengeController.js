const challengeService = require('../services/challengeService');

const badRequest = message =>
  Object.assign(new Error(message), { status: 400 });

function positiveId(value, name) {
  if (!Number.isSafeInteger(value) || value < 1) {
    throw badRequest(name + ' måste vara ett positivt heltal.');
  }
  return value;
}

function runId(req) {
  if (!/^[1-9]\d*$/.test(req.params.runId)) {
    throw badRequest('Ogiltigt omgångs-ID.');
  }
  return positiveId(Number(req.params.runId), 'runId');
}

function requestKey(value) {
  const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

  if (typeof value !== 'string' || value.length !== 36 || !uuid.test(value)) {
    throw badRequest('requestKey måste vara ett UUID v4.');
  }
  return value.toLowerCase();
}

exports.getCaesarStatus = async (req, res) => {
  res.json(await challengeService.getCaesarStatus(req.user.id));
};

exports.startRun = async (req, res) => {
  res.json(await challengeService.startRun({
    userId: req.user.id,
    requestKey: requestKey(req.body?.requestKey),
  }));
};

exports.getRun = async (req, res) => {
  res.json(await challengeService.getRun(req.user.id, runId(req)));
};

exports.saveAnswer = async (req, res) => {
  res.json(await challengeService.saveAnswer({
    userId: req.user.id,
    runId: runId(req),
    questionId: positiveId(req.body?.questionId, 'questionId'),
    selectedOptionId: positiveId(req.body?.selectedOptionId, 'selectedOptionId'),
    requestKey: requestKey(req.body?.requestKey),
  }));
};
