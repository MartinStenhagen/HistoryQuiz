USE historyQuizDb;

INSERT INTO topics (name , description)
VALUES ('Andra världskriget','Testfrågor för endpoints om andra världskriget.' );

INSERT INTO questions (
    topic_id,
    question_text,
    explanation,
    difficulty
)
VALUES (
           1,
           'Vilken term brukar man använda för att beskriva första dagen av landstigningarna i Normandie den 6 juni 1944?',
           'Termen Dagen D användes ursprungligen av de allierande under planeringsfasen innan det fanns ett bestämt datum.',
           1
       );

INSERT INTO answer_options (
    question_id,
    option_text,
    sort_order,
    is_correct
)
VALUES
    (1, 'Den stora dagen',       1, 0),
    (1, 'VE-Day', 2, 0),
    (1, 'Dagen D',    3, 1),
    (1, 'Landstigningen',   4, 0);

UPDATE historyQuizDb.questions
SET status = 'published',
    published_at = UTC_TIMESTAMP(6)
WHERE id = 1;

USE historyQuizDb;

START TRANSACTION;

SET @ww2_topic_id = 1;

INSERT INTO questions (
    topic_id, question_text, explanation,
    difficulty, status, published_at
)
VALUES (
           @ww2_topic_id,
           'Vilket land invaderade Tyskland den 1 september 1939?',
           'Tyskland invaderade Polen den 1 september 1939. Invasionen markerar början på andra världskriget i Europa.',
           1,
           'published',
           UTC_TIMESTAMP(6)
       );

SET @new_question_id = LAST_INSERT_ID();

INSERT INTO answer_options (
    question_id, option_text, sort_order, is_correct
)
VALUES
    (@new_question_id, 'Frankrike', 1, 0),
    (@new_question_id, 'Polen',     2, 1),
    (@new_question_id, 'Norge',     3, 0),
    (@new_question_id, 'Grekland',  4, 0);


INSERT INTO questions (
    topic_id, question_text, explanation,
    difficulty, status, published_at
)
VALUES (
           @ww2_topic_id,
           'Vad heter Storbritanniens flygvapen, som försvarade landet under slaget om Storbritannien 1940?',
           'Royal Air Force, förkortat RAF, försvarade Storbritannien mot det tyska flygvapnet Luftwaffe under slaget om Storbritannien 1940.',
           1,
           'published',
           UTC_TIMESTAMP(6)
       );

SET @new_question_id = LAST_INSERT_ID();

INSERT INTO answer_options (
    question_id, option_text, sort_order, is_correct
)
VALUES
    (@new_question_id, 'Royal Air Force', 1, 1),
    (@new_question_id, 'Luftwaffe',       2, 0),
    (@new_question_id, 'Royal Navy',      3, 0),
    (@new_question_id, 'Wehrmacht',       4, 0);


INSERT INTO questions (
    topic_id, question_text, explanation,
    difficulty, status, published_at
)
VALUES (
           @ww2_topic_id,
           'I vilket land utkämpades det andra slaget vid El Alamein 1942?',
           'Det andra slaget vid El Alamein utkämpades i Egypten mellan den 23 oktober och den 4 november 1942.',
           2,
           'published',
           UTC_TIMESTAMP(6)
       );

SET @new_question_id = LAST_INSERT_ID();

INSERT INTO answer_options (
    question_id, option_text, sort_order, is_correct
)
VALUES
    (@new_question_id, 'Italien',   1, 0),
    (@new_question_id, 'Frankrike', 2, 0),
    (@new_question_id, 'Egypten',   3, 1),
    (@new_question_id, 'Polen',     4, 0);


INSERT INTO questions (
    topic_id, question_text, explanation,
    difficulty, status, published_at
)
VALUES (
           @ww2_topic_id,
           'Vilket år tog andra världskriget slut i Europa?',
           'Kriget i Europa avslutades i maj 1945 efter Tysklands kapitulation.',
           1,
           'published',
           UTC_TIMESTAMP(6)
       );

SET @new_question_id = LAST_INSERT_ID();

INSERT INTO answer_options (
    question_id, option_text, sort_order, is_correct
)
VALUES
    (@new_question_id, '1940', 1, 0),
    (@new_question_id, '1942', 2, 0),
    (@new_question_id, '1944', 3, 0),
    (@new_question_id, '1945', 4, 1);

COMMIT;

-- Tillägg: Romarriket (5 frågor).
-- Om de befintliga frågorna redan är inlagda, kör endast blocket nedan
-- från USE historyQuizDb till och med COMMIT. Kör tillägget en gång.

USE historyQuizDb;

START TRANSACTION;

INSERT INTO topics (name, description)
SELECT 'Romarriket', 'Frågor om Romarrikets kejsare, språk och historia.'
WHERE NOT EXISTS (
    SELECT 1 FROM topics WHERE name = 'Romarriket'
);

SET @roman_topic_id = (SELECT id FROM topics WHERE name = 'Romarriket');

INSERT INTO questions (
    topic_id, question_text, explanation,
    difficulty, status, published_at
)
VALUES (
           @roman_topic_id,
           'Vad hette Romarrikets första kejsare?',
           'Augustus räknas som Romarrikets första kejsare. Han hette tidigare Octavianus och fick namnet Augustus år 27 f.Kr.',
           1,
           'published',
           UTC_TIMESTAMP(6)
       );

SET @new_question_id = LAST_INSERT_ID();

INSERT INTO answer_options (
    question_id, option_text, sort_order, is_correct
)
VALUES
    (@new_question_id, 'Julius Caesar', 1, 0),
    (@new_question_id, 'Augustus',      2, 1),
    (@new_question_id, 'Nero',          3, 0),
    (@new_question_id, 'Konstantin',    4, 0);


INSERT INTO questions (
    topic_id, question_text, explanation,
    difficulty, status, published_at
)
VALUES (
           @roman_topic_id,
           'Vilken stad var Romarrikets ursprungliga huvudstad?',
           'Rom var rikets ursprungliga huvudstad och gav Romarriket dess namn.',
           1,
           'published',
           UTC_TIMESTAMP(6)
       );

SET @new_question_id = LAST_INSERT_ID();

INSERT INTO answer_options (
    question_id, option_text, sort_order, is_correct
)
VALUES
    (@new_question_id, 'Aten',       1, 0),
    (@new_question_id, 'Alexandria', 2, 0),
    (@new_question_id, 'Kartago',    3, 0),
    (@new_question_id, 'Rom',        4, 1);


INSERT INTO questions (
    topic_id, question_text, explanation,
    difficulty, status, published_at
)
VALUES (
           @roman_topic_id,
           'Vilket språk talades av romarna och blev grunden för bland annat italienska, franska och spanska?',
           'Latin talades av romarna. De romanska språken, däribland italienska, franska och spanska, utvecklades ur det talade latinet.',
           1,
           'published',
           UTC_TIMESTAMP(6)
       );

SET @new_question_id = LAST_INSERT_ID();

INSERT INTO answer_options (
    question_id, option_text, sort_order, is_correct
)
VALUES
    (@new_question_id, 'Latin',     1, 1),
    (@new_question_id, 'Grekiska',  2, 0),
    (@new_question_id, 'Persiska',  3, 0),
    (@new_question_id, 'Egyptiska', 4, 0);


INSERT INTO questions (
    topic_id, question_text, explanation,
    difficulty, status, published_at
)
VALUES (
           @roman_topic_id,
           'Vad heter den stora amfiteatern i Rom där bland annat gladiatorspel hölls?',
           'Colosseum är en amfiteater i Rom som användes för bland annat gladiatorspel och andra offentliga skådespel.',
           1,
           'published',
           UTC_TIMESTAMP(6)
       );

SET @new_question_id = LAST_INSERT_ID();

INSERT INTO answer_options (
    question_id, option_text, sort_order, is_correct
)
VALUES
    (@new_question_id, 'Pantheon',       1, 0),
    (@new_question_id, 'Forum Romanum',  2, 0),
    (@new_question_id, 'Colosseum',      3, 1),
    (@new_question_id, 'Circus Maximus', 4, 0);


INSERT INTO questions (
    topic_id, question_text, explanation,
    difficulty, status, published_at
)
VALUES (
           @roman_topic_id,
           'Vilket år brukar anges som året då Västrom föll?',
           'År 476 e.Kr. avsattes kejsaren Romulus Augustulus. Händelsen brukar räknas som slutet på Västrom, medan Östrom levde vidare.',
           2,
           'published',
           UTC_TIMESTAMP(6)
       );

SET @new_question_id = LAST_INSERT_ID();

INSERT INTO answer_options (
    question_id, option_text, sort_order, is_correct
)
VALUES
    (@new_question_id, '1066 e.Kr.', 1, 0),
    (@new_question_id, '1453 e.Kr.', 2, 0),
    (@new_question_id, '800 e.Kr.',  3, 0),
    (@new_question_id, '476 e.Kr.',  4, 1);

COMMIT;

-- Tillägg: kvalificering på nivå 3 och Caesars utmaning.
-- Kräver att backend/database/challenge.sql har körts först.
-- Kör bara detta tillägg om äldre frågor redan finns i databasen.
-- Tillägget kan köras igen: befintliga frågekoder, alternativ och regler
-- skrivs inte över. Tidigare block i den här filen är inte återkörbara.
-- Kör hela tillägget i samma anslutning; avbryt och gör ROLLBACK vid fel.
-- De vanliga frågorna publiceras. Utmaningen skapas inaktiv och dess
-- frågor som utkast tills steg 3 och filtren för vanliga quiz är införda.
-- Historiskt underlag:
-- https://www.worldhistory.org/Roman_Republic/
-- https://www.metmuseum.org/de/perspectives/mary-beard-silver-caesars-1
-- https://www.britishmuseum.org/collection/term/BIOG57074
-- https://penelope.uchicago.edu/encyclopaedia_romana/calendar/romancalendar.html

USE historyQuizDb;

START TRANSACTION;

INSERT INTO topics (name, description)
VALUES ('Romarriket', 'Frågor om det antika Rom.')
ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);

SET @caesar_topic_id = LAST_INSERT_ID();

INSERT INTO challenges (
    code, name, character_name, character_key, topic_id,
    required_difficulty, required_unique_correct,
    question_count, correct_to_pass, is_active
)
VALUES (
    'CAESAR_CHALLENGE', 'Caesars utmaning', 'Julius Caesar', 'caesar',
    @caesar_topic_id, 3, 5, 5, 4, 0
)
ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);

SET @caesar_challenge_id = LAST_INSERT_ID();

-- ROM_L3_01: vanlig nivå 3-fråga.
INSERT INTO questions (
    question_code, topic_id, question_text, explanation,
    question_kind, difficulty, status, published_at
)
VALUES (
    'ROM_L3_01', @caesar_topic_id,
    'Varför hade den romerska republiken två konsuler?',
    'De delade makten och kunde stoppa varandras beslut.',
    'regular', 3, 'published', UTC_TIMESTAMP(6)
)
ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);

SET @caesar_question_id = LAST_INSERT_ID();

INSERT INTO answer_options (
    question_id, option_text, sort_order, is_correct
)
VALUES
    (@caesar_question_id, 'En styrde bara på natten', 1, 0),
    (@caesar_question_id, 'För att begränsa en ensam ledares makt', 2, 1),
    (@caesar_question_id, 'De styrde varsin planet', 3, 0),
    (@caesar_question_id, 'En bestämde bara över maten', 4, 0)
ON DUPLICATE KEY UPDATE id = id;

-- ROM_L3_02: vanlig nivå 3-fråga.
INSERT INTO questions (
    question_code, topic_id, question_text, explanation,
    question_kind, difficulty, status, published_at
)
VALUES (
    'ROM_L3_02', @caesar_topic_id,
    'Hur länge varade en konsuls vanliga ämbetsperiod?',
    'Konsuler valdes normalt för ett år.',
    'regular', 3, 'published', UTC_TIMESTAMP(6)
)
ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);

SET @caesar_question_id = LAST_INSERT_ID();

INSERT INTO answer_options (
    question_id, option_text, sort_order, is_correct
)
VALUES
    (@caesar_question_id, 'En månad', 1, 0),
    (@caesar_question_id, 'Tio år', 2, 0),
    (@caesar_question_id, 'Ett år', 3, 1),
    (@caesar_question_id, 'Hela livet', 4, 0)
ON DUPLICATE KEY UPDATE id = id;

-- ROM_L3_03: vanlig nivå 3-fråga.
INSERT INTO questions (
    question_code, topic_id, question_text, explanation,
    question_kind, difficulty, status, published_at
)
VALUES (
    'ROM_L3_03', @caesar_topic_id,
    'Vilken grupp skulle folktribunerna företräda?',
    'Folktribunerna företrädde plebejerna.',
    'regular', 3, 'published', UTC_TIMESTAMP(6)
)
ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);

SET @caesar_question_id = LAST_INSERT_ID();

INSERT INTO answer_options (
    question_id, option_text, sort_order, is_correct
)
VALUES
    (@caesar_question_id, 'Plebejerna', 1, 1),
    (@caesar_question_id, 'Bara kungafamiljen', 2, 0),
    (@caesar_question_id, 'Bara utländska kungar', 3, 0),
    (@caesar_question_id, 'Bara generalerna', 4, 0)
ON DUPLICATE KEY UPDATE id = id;

-- ROM_L3_04: vanlig nivå 3-fråga.
INSERT INTO questions (
    question_code, topic_id, question_text, explanation,
    question_kind, difficulty, status, published_at
)
VALUES (
    'ROM_L3_04', @caesar_topic_id,
    'Vilken uppgift hade senaten under republiken?',
    'Senaten gav råd och hade stort inflytande över statens angelägenheter.',
    'regular', 3, 'published', UTC_TIMESTAMP(6)
)
ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);

SET @caesar_question_id = LAST_INSERT_ID();

INSERT INTO answer_options (
    question_id, option_text, sort_order, is_correct
)
VALUES
    (@caesar_question_id, 'Att utbilda alla gladiatorer', 1, 0),
    (@caesar_question_id, 'Att välja faraoner', 2, 0),
    (@caesar_question_id, 'Att styra de grekiska gudarna', 3, 0),
    (@caesar_question_id, 'Att ge råd om hur staten skulle styras', 4, 1)
ON DUPLICATE KEY UPDATE id = id;

-- ROM_L3_05: vanlig nivå 3-fråga.
INSERT INTO questions (
    question_code, topic_id, question_text, explanation,
    question_kind, difficulty, status, published_at
)
VALUES (
    'ROM_L3_05', @caesar_topic_id,
    'Vilket styrelseskick hade Rom mellan kungatiden och kejsartiden?',
    'Under denna period var Rom en republik.',
    'regular', 3, 'published', UTC_TIMESTAMP(6)
)
ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);

SET @caesar_question_id = LAST_INSERT_ID();

INSERT INTO answer_options (
    question_id, option_text, sort_order, is_correct
)
VALUES
    (@caesar_question_id, 'Absolut kungadöme', 1, 0),
    (@caesar_question_id, 'Republik', 2, 1),
    (@caesar_question_id, 'Faraoniskt rike', 3, 0),
    (@caesar_question_id, 'Vikingating', 4, 0)
ON DUPLICATE KEY UPDATE id = id;

-- CAESAR_01: utmaningsfråga (utkast).
INSERT INTO questions (
    question_code, topic_id, question_text, explanation,
    question_kind, difficulty, status, published_at
)
VALUES (
    'CAESAR_01', @caesar_topic_id,
    'Vilken titel hade Julius Caesar mot slutet av sitt liv?',
    'Caesar utsågs till diktator på livstid.',
    'challenge', 3, 'draft', NULL
)
ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);

SET @caesar_question_id = LAST_INSERT_ID();

INSERT INTO answer_options (
    question_id, option_text, sort_order, is_correct
)
VALUES
    (@caesar_question_id, 'Farao', 1, 0),
    (@caesar_question_id, 'Diktator', 2, 1),
    (@caesar_question_id, 'Vikingakung', 3, 0),
    (@caesar_question_id, 'Påve', 4, 0)
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO challenge_questions (challenge_id, question_id, sort_order)
SELECT @caesar_challenge_id, @caesar_question_id, 1
WHERE NOT EXISTS (
    SELECT 1 FROM challenge_questions
    WHERE challenge_id = @caesar_challenge_id
        AND question_id = @caesar_question_id
);

-- CAESAR_02: utmaningsfråga (utkast).
INSERT INTO questions (
    question_code, topic_id, question_text, explanation,
    question_kind, difficulty, status, published_at
)
VALUES (
    'CAESAR_02', @caesar_topic_id,
    'Vem adopterade Caesar genom sitt testamente?',
    'Octavianus adopterades genom Caesars testamente och blev senare Augustus.',
    'challenge', 3, 'draft', NULL
)
ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);

SET @caesar_question_id = LAST_INSERT_ID();

INSERT INTO answer_options (
    question_id, option_text, sort_order, is_correct
)
VALUES
    (@caesar_question_id, 'Nero', 1, 0),
    (@caesar_question_id, 'Hannibal', 2, 0),
    (@caesar_question_id, 'Octavianus', 3, 1),
    (@caesar_question_id, 'Romulus', 4, 0)
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO challenge_questions (challenge_id, question_id, sort_order)
SELECT @caesar_challenge_id, @caesar_question_id, 2
WHERE NOT EXISTS (
    SELECT 1 FROM challenge_questions
    WHERE challenge_id = @caesar_challenge_id
        AND question_id = @caesar_question_id
);

-- CAESAR_03: utmaningsfråga (utkast).
INSERT INTO questions (
    question_code, topic_id, question_text, explanation,
    question_kind, difficulty, status, published_at
)
VALUES (
    'CAESAR_03', @caesar_topic_id,
    'Vilken månad har fått sitt namn efter Julius Caesar?',
    'Månaden juli fick sitt namn till Caesars ära.',
    'challenge', 3, 'draft', NULL
)
ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);

SET @caesar_question_id = LAST_INSERT_ID();

INSERT INTO answer_options (
    question_id, option_text, sort_order, is_correct
)
VALUES
    (@caesar_question_id, 'Juli', 1, 1),
    (@caesar_question_id, 'Mars', 2, 0),
    (@caesar_question_id, 'September', 3, 0),
    (@caesar_question_id, 'December', 4, 0)
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO challenge_questions (challenge_id, question_id, sort_order)
SELECT @caesar_challenge_id, @caesar_question_id, 3
WHERE NOT EXISTS (
    SELECT 1 FROM challenge_questions
    WHERE challenge_id = @caesar_challenge_id
        AND question_id = @caesar_question_id
);

-- CAESAR_04: utmaningsfråga (utkast).
INSERT INTO questions (
    question_code, topic_id, question_text, explanation,
    question_kind, difficulty, status, published_at
)
VALUES (
    'CAESAR_04', @caesar_topic_id,
    'Vad kallas kalendern som infördes genom Caesars kalenderreform?',
    'Den kallas den julianska kalendern.',
    'challenge', 3, 'draft', NULL
)
ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);

SET @caesar_question_id = LAST_INSERT_ID();

INSERT INTO answer_options (
    question_id, option_text, sort_order, is_correct
)
VALUES
    (@caesar_question_id, 'Vikingakalendern', 1, 0),
    (@caesar_question_id, 'Den gregorianska kalendern', 2, 0),
    (@caesar_question_id, 'Månkalendern', 3, 0),
    (@caesar_question_id, 'Den julianska kalendern', 4, 1)
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO challenge_questions (challenge_id, question_id, sort_order)
SELECT @caesar_challenge_id, @caesar_question_id, 4
WHERE NOT EXISTS (
    SELECT 1 FROM challenge_questions
    WHERE challenge_id = @caesar_challenge_id
        AND question_id = @caesar_question_id
);

-- CAESAR_05: utmaningsfråga (utkast).
INSERT INTO questions (
    question_code, topic_id, question_text, explanation,
    question_kind, difficulty, status, published_at
)
VALUES (
    'CAESAR_05', @caesar_topic_id,
    'Vilket år började Caesars nya kalender användas?',
    'Den julianska kalendern började användas år 45 f.Kr.',
    'challenge', 3, 'draft', NULL
)
ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);

SET @caesar_question_id = LAST_INSERT_ID();

INSERT INTO answer_options (
    question_id, option_text, sort_order, is_correct
)
VALUES
    (@caesar_question_id, '476 e.Kr.', 1, 0),
    (@caesar_question_id, '45 f.Kr.', 2, 1),
    (@caesar_question_id, '1523 e.Kr.', 3, 0),
    (@caesar_question_id, '27 f.Kr.', 4, 0)
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO challenge_questions (challenge_id, question_id, sort_order)
SELECT @caesar_challenge_id, @caesar_question_id, 5
WHERE NOT EXISTS (
    SELECT 1 FROM challenge_questions
    WHERE challenge_id = @caesar_challenge_id
        AND question_id = @caesar_question_id
);

COMMIT;
