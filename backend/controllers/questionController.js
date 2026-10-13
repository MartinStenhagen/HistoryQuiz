const questionService = require('../services/questionService');

exports.getQuestions = async (req, res) => {
    // Query-parametrar kommer som text. Standardvärdet är fem frågor.
    const rawLimit = req.query.limit ?? '5';
    const limit = Number(rawLimit);

    if (
        typeof rawLimit !== 'string' ||
        !/^\d+$/.test(rawLimit) ||
        !Number.isInteger(limit) ||
        limit < 1 ||
        limit > 20
    ) {
        return res.status(400).json({
            error: 'limit måste vara ett heltal mellan 1 och 20.',
        });
    }
    try {
        const questions = await questionService.getQuestions(limit);
        
        return res.status(200).json({questions});
    } catch (error) {
        console.error('Kunde inte hämta frågor:', error);
        return res.status(500).json({ error: 'Kunde inte hämta frågor.' });
    }
};