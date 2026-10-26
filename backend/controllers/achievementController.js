const withUserTransaction = require('../database/withUserTransaction');
const achievementService = require('../services/achievementService');

exports.getMyAchievements = async (req, res) => {
  const progress = await withUserTransaction(req.user.id, (connection) =>
    achievementService.readProgress(connection, req.user.id)
  );

  res.json({ userId: req.user.id, ...progress });
};
