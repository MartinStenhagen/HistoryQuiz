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