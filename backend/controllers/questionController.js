const questionService = require('../services/questionService');

exports.getQuestions = async (req, res) => {
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

    // null betyder att inget ämnesfilter ska användas.
    let topicId = null;
    const rawTopicId = req.query.topicId;

    if (rawTopicId !== undefined) {
        if (
            typeof rawTopicId !== 'string' ||
            !/^\d+$/.test(rawTopicId)
        ) {
            return res.status(400).json({
                error: 'topicId måste vara ett positivt heltal.',
            });
        }

        topicId = Number(rawTopicId);

        if (!Number.isSafeInteger(topicId) || topicId < 1) {
            return res.status(400).json({
                error: 'topicId måste vara ett positivt heltal.',
            });
        }
    }

    try {
        const questions = await questionService.getQuestions(
            limit,
            topicId
        );

        return res.status(200).json({ questions });
    } catch (error) {
        console.error('Kunde inte hämta frågor:', error);

        return res.status(500).json({
            error: 'Kunde inte hämta frågor.',
        });
    }
};

exports.answerQuestion = async (req, res) => {
    const questionId = Number(req.params.id);
    const selectedOptionId = req.body?.selectedOptionId;

    // Frågans ID kommer från URL:en.
    if (
        !/^\d+$/.test(req.params.id) ||
        !Number.isSafeInteger(questionId) ||
        questionId < 1
    ) {
        return res.status(400).json({
            error: 'Frågans ID måste vara ett positivt heltal.',
        });
    }

    // Alternativets ID ska skickas som ett tal i JSON-body.
    if (
        !Number.isSafeInteger(selectedOptionId) ||
        selectedOptionId < 1
    ) {
        return res.status(400).json({
            error: 'selectedOptionId måste vara ett positivt heltal.',
        });
    }

    try {
        const result = await questionService.answerQuestion(
            questionId,
            selectedOptionId
        );

        if (result === null) {
            return res.status(404).json({
                error: 'Frågan finns inte eller är inte spelbar.',
            });
        }

        return res.status(200).json(result);
    } catch (error) {
        if (error.code === 'INVALID_OPTION') {
            return res.status(400).json({
                error: error.message,
            });
        }

        console.error('Kunde inte rätta svaret:', error);

        return res.status(500).json({
            error: 'Kunde inte rätta svaret. Försök igen senare.',
        });
    }
};