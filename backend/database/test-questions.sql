-- Test frågor för quizet
USE historyQuizDb;

INSERT INTO topics (name, description)
VALUES (
    'Andra världskriget',
    'Testfrågor om andra världskriget.'
)
ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);

SET @topic_id = LAST_INSERT_ID();

-- Fråga 1
INSERT INTO questions (topic_id, question_text, explanation, difficulty, status, published_at)
VALUES (
    @topic_id,
    'Vilket år började andra världskriget?',
    'Andra världskriget började 1939 när Tyskland invaderade Polen.',
    1, 'published', UTC_TIMESTAMP(6)
);
SET @q = LAST_INSERT_ID();
INSERT INTO answer_options (question_id, option_text, sort_order, is_correct) VALUES
(@q, '1935', 1, 0),
(@q, '1939', 2, 1),
(@q, '1941', 3, 0),
(@q, '1945', 4, 0);

-- Fråga 2
INSERT INTO questions (topic_id, question_text, explanation, difficulty, status, published_at)
VALUES (
    @topic_id,
    'Vilket land invaderade Tyskland 1939?',
    'Tyskland invaderade Polen den 1 september 1939.',
    1, 'published', UTC_TIMESTAMP(6)
);
SET @q = LAST_INSERT_ID();
INSERT INTO answer_options (question_id, option_text, sort_order, is_correct) VALUES
(@q, 'Frankrike', 1, 0),
(@q, 'Danmark', 2, 0),
(@q, 'Polen', 3, 1),
(@q, 'Norge', 4, 0);

-- Fråga 3
INSERT INTO questions (topic_id, question_text, explanation, difficulty, status, published_at)
VALUES (
    @topic_id,
    'Vilket år tog kriget slut i Europa?',
    'Tyskland kapitulerade i maj 1945.',
    1, 'published', UTC_TIMESTAMP(6)
);
SET @q = LAST_INSERT_ID();
INSERT INTO answer_options (question_id, option_text, sort_order, is_correct) VALUES
(@q, '1943', 1, 0),
(@q, '1944', 2, 0),
(@q, '1945', 3, 1),
(@q, '1946', 4, 0);

-- Fråga 4
INSERT INTO questions (topic_id, question_text, explanation, difficulty, status, published_at)
VALUES (
    @topic_id,
    'Vad kallades landstigningen i Normandie den 6 juni 1944?',
    'Operation Overlord var de allierades operation för landstigningen i Normandie, vars första dag kallas Dagen D.',
    1, 'published', UTC_TIMESTAMP(6)
);
SET @q = LAST_INSERT_ID();
INSERT INTO answer_options (question_id, option_text, sort_order, is_correct) VALUES
(@q, 'Operation Barbarossa', 1, 0),
(@q, 'Dagen D', 2, 1),
(@q, 'Operation Torch', 3, 0),
(@q, 'Operation Market Garden', 4, 0);

-- Fråga 5
INSERT INTO questions (topic_id, question_text, explanation, difficulty, status, published_at)
VALUES (
    @topic_id,
    'Vem var Storbritanniens premiärminister under stora delar av kriget?',
    'Winston Churchill blev premiärminister 1940.',
    1, 'published', UTC_TIMESTAMP(6)
);
SET @q = LAST_INSERT_ID();
INSERT INTO answer_options (question_id, option_text, sort_order, is_correct) VALUES
(@q, 'Neville Chamberlain', 1, 0),
(@q, 'Winston Churchill', 2, 1),
(@q, 'Charles de Gaulle', 3, 0),
(@q, 'Franklin D. Roosevelt', 4, 0);

-- Fråga 6
INSERT INTO questions (topic_id, question_text, explanation, difficulty, status, published_at)
VALUES (
    @topic_id,
    'Vilka länder var bland de viktigaste allierade under kriget?',
    'Storbritannien, Sovjetunionen och USA var centrala allierade mot axelmakterna.',
    2, 'published', UTC_TIMESTAMP(6)
);
SET @q = LAST_INSERT_ID();
INSERT INTO answer_options (question_id, option_text, sort_order, is_correct) VALUES
(@q, 'Tyskland, Italien och Japan', 1, 0),
(@q, 'Storbritannien, USA och Sovjetunionen', 2, 1),
(@q, 'Spanien, Portugal och Schweiz', 3, 0),
(@q, 'Sverige, Norge och Finland', 4, 0);

-- Fråga 7
INSERT INTO questions (topic_id, question_text, explanation, difficulty, status, published_at)
VALUES (
    @topic_id,
    'Vad kallades Nazitysklands politiska ledare?',
    'Adolf Hitler var Nazitysklands diktator.',
    1, 'published', UTC_TIMESTAMP(6)
);
SET @q = LAST_INSERT_ID();
INSERT INTO answer_options (question_id, option_text, sort_order, is_correct) VALUES
(@q, 'Benito Mussolini', 1, 0),
(@q, 'Joseph Stalin', 2, 0),
(@q, 'Adolf Hitler', 3, 1),
(@q, 'Winston Churchill', 4, 0);

-- Fråga 8
INSERT INTO questions (topic_id, question_text, explanation, difficulty, status, published_at)
VALUES (
    @topic_id,
    'Vilket land attackerade Pearl Harbor 1941?',
    'Japan attackerade den amerikanska flottbasen Pearl Harbor den 7 december 1941.',
    2, 'published', UTC_TIMESTAMP(6)
);
SET @q = LAST_INSERT_ID();
INSERT INTO answer_options (question_id, option_text, sort_order, is_correct) VALUES
(@q, 'Italien', 1, 0),
(@q, 'Japan', 2, 1),
(@q, 'Tyskland', 3, 0),
(@q, 'Sovjetunionen', 4, 0);

-- Fråga 9
INSERT INTO questions (topic_id, question_text, explanation, difficulty, status, published_at)
VALUES (
    @topic_id,
    'Vad var Förintelsen?',
    'Förintelsen var Nazitysklands systematiska förföljelse och mord på sex miljoner judar, samt förföljelse och mord på andra grupper.',
    2, 'published', UTC_TIMESTAMP(6)
);
SET @q = LAST_INSERT_ID();
INSERT INTO answer_options (question_id, option_text, sort_order, is_correct) VALUES
(@q, 'En fredskonferens', 1, 0),
(@q, 'En militärallians', 2, 0),
(@q, 'Nazisternas folkmord på Europas judar', 3, 1),
(@q, 'Ett fredsavtal', 4, 0);

-- Fråga 10
INSERT INTO questions (topic_id, question_text, explanation, difficulty, status, published_at)
VALUES (
    @topic_id,
    'Vilka två japanska städer utsattes för amerikanska atombomber 1945?',
    'Atombomber fälldes över Hiroshima den 6 augusti och Nagasaki den 9 augusti 1945.',
    2, 'published', UTC_TIMESTAMP(6)
);
SET @q = LAST_INSERT_ID();
INSERT INTO answer_options (question_id, option_text, sort_order, is_correct) VALUES
(@q, 'Tokyo och Kyoto', 1, 0),
(@q, 'Hiroshima och Nagasaki', 2, 1),
(@q, 'Osaka och Kobe', 3, 0),
(@q, 'Sapporo och Yokohama', 4, 0);

SELECT q.id, q.question_text, ao.option_text, ao.is_correct
FROM questions q
JOIN answer_options ao ON ao.question_id = q.id
WHERE q.topic_id = @topic_id
ORDER BY q.id, ao.sort_order;
