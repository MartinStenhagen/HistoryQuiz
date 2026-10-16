const topicService = require('../services/topicService');

exports.getTopics = async (req, res) => {
    try {
        const topics = await topicService.getTopics();

        return res.status(200).json({ topics });
    } catch (error) {
        console.error('Kunde inte hämta ämnen:', error);

        return res.status(500).json({
            error: 'Kunde inte hämta ämnen.',
        });
    }
};
