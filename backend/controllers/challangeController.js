const challangeService = require('../services/challangeService');

exports.getCaesarStatus = async (req, res) => {
    const status = await challangeService.getCaesarStatus(req.user.id);
    res.json(status);
}
