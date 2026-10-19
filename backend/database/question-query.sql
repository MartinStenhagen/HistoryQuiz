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