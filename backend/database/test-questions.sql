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

-- Mer historiska frågor
-- Forntida Egypten
INSERT INTO topics (name, description)
VALUES ('Forntida Egypten', 'Frågor om det forntida Egyptens historia')
ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);

SET @topic_id = LAST_INSERT_ID();

INSERT INTO questions
(topic_id, question_text, explanation, difficulty, status, published_at)
VALUES
(@topic_id, 'Vilken flod var viktig för det forntida Egypten?',
 'Nilen gav vatten och bördig jord till jordbruket.', 1, 'published', UTC_TIMESTAMP(6)),
(@topic_id, 'Vad kallades de egyptiska bildtecknen?',
 'De egyptiska bildtecknen kallas hieroglyfer.', 2, 'published', UTC_TIMESTAMP(6)),
(@topic_id, 'Vilken egyptisk farao förknippas med graven som hittades nästan orörd 1922?',
 'Tutankhamons grav upptäcktes av Howard Carter och hans team.', 3, 'published', UTC_TIMESTAMP(6));

SET @question_id = LAST_INSERT_ID() - 2;

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
(@question_id, 'Nilen', 1, TRUE),
(@question_id, 'Amazonas', 2, FALSE),
(@question_id, 'Donau', 3, FALSE),
(@question_id, 'Rhen', 4, FALSE);

SET @question_id = @question_id + 1;

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
(@question_id, 'Kilskrift', 1, FALSE),
(@question_id, 'Hieroglyfer', 2, TRUE),
(@question_id, 'Runor', 3, FALSE),
(@question_id, 'Alfabetisk skrift', 4, FALSE);

SET @question_id = @question_id + 1;

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
(@question_id, 'Ramses II', 1, FALSE),
(@question_id, 'Kleopatra', 2, FALSE),
(@question_id, 'Tutankhamon', 3, TRUE),
(@question_id, 'Akhenaton', 4, FALSE);


-- Vikingatiden
INSERT INTO topics (name, description)
VALUES ('Vikingatiden', 'Frågor om vikingarnas liv och resor')
ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);

SET @topic_id = LAST_INSERT_ID();

INSERT INTO questions
(topic_id, question_text, explanation, difficulty, status, published_at)
VALUES
(@topic_id, 'Vad använde vikingarna främst för att resa över havet?',
 'Vikingarna använde bland annat långskepp.', 1, 'published', UTC_TIMESTAMP(6)),
(@topic_id, 'Vad kallades vikingarnas gamla nordiska skriftsymboler?',
 'Runor användes för att skriva i det fornnordiska samhället.', 2, 'published', UTC_TIMESTAMP(6)),
(@topic_id, 'Vilken vikingaledare förknippas med upptäckten av Grönland?',
 'Erik den röde förknippas med den nordiska bosättningen på Grönland.', 3, 'published', UTC_TIMESTAMP(6));

SET @question_id = LAST_INSERT_ID() - 2;

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
(@question_id, 'Långskepp', 1, TRUE),
(@question_id, 'Ångbåtar', 2, FALSE),
(@question_id, 'Ubåtar', 3, FALSE),
(@question_id, 'Tåg', 4, FALSE);

SET @question_id = @question_id + 1;

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
(@question_id, 'Hieroglyfer', 1, FALSE),
(@question_id, 'Runor', 2, TRUE),
(@question_id, 'Latinska bokstäver', 3, FALSE),
(@question_id, 'Kilskrift', 4, FALSE);

SET @question_id = @question_id + 1;

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
(@question_id, 'Harald Blåtand', 1, FALSE),
(@question_id, 'Erik den röde', 2, TRUE),
(@question_id, 'Olof Skötkonung', 3, FALSE),
(@question_id, 'Gustav Vasa', 4, FALSE);


-- Sveriges historia
INSERT INTO topics (name, description)
VALUES ('Sveriges historia', 'Frågor om viktiga händelser i Sveriges historia')
ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);

SET @topic_id = LAST_INSERT_ID();

INSERT INTO questions
(topic_id, question_text, explanation, difficulty, status, published_at)
VALUES
(@topic_id, 'Vilket land ligger Sverige i för världsdel?',
 'Sverige ligger i Europa.', 1, 'published', UTC_TIMESTAMP(6)),
(@topic_id, 'Vilket år blev Gustav Vasa kung av Sverige?',
 'Gustav Vasa blev kung år 1523.', 2, 'published', UTC_TIMESTAMP(6)),
(@topic_id, 'Vilket år upplöstes unionen mellan Sverige och Norge?',
 'Unionen mellan Sverige och Norge upplöstes 1905.', 3, 'published', UTC_TIMESTAMP(6));

SET @question_id = LAST_INSERT_ID() - 2;

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
(@question_id, 'Europa', 1, TRUE),
(@question_id, 'Afrika', 2, FALSE),
(@question_id, 'Asien', 3, FALSE),
(@question_id, 'Sydamerika', 4, FALSE);

SET @question_id = @question_id + 1;

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
(@question_id, '1397', 1, FALSE),
(@question_id, '1523', 2, TRUE),
(@question_id, '1611', 3, FALSE),
(@question_id, '1809', 4, FALSE);

SET @question_id = @question_id + 1;

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
(@question_id, '1814', 1, FALSE),
(@question_id, '1865', 2, FALSE),
(@question_id, '1905', 3, TRUE),
(@question_id, '1918', 4, FALSE);

