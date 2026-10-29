USE historyQuizDb;

-- Befintliga frågor blir automatiskt vanliga quizfrågor.
-- question_code ger nya seed-frågor en stabil identifierare.
ALTER TABLE questions
    ADD COLUMN question_code VARCHAR(64) NULL,
    ADD COLUMN question_kind ENUM('regular', 'challenge')
        NOT NULL DEFAULT 'regular',
    ADD UNIQUE KEY uq_questions_code (question_code);

CREATE TABLE challenges (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    character_name VARCHAR(100) NOT NULL,
    character_key VARCHAR(50) NOT NULL,
    topic_id INT UNSIGNED NOT NULL,

    required_difficulty TINYINT UNSIGNED NOT NULL DEFAULT 3,
    required_unique_correct SMALLINT UNSIGNED NOT NULL DEFAULT 5,
    question_count TINYINT UNSIGNED NOT NULL DEFAULT 5,
    correct_to_pass TINYINT UNSIGNED NOT NULL DEFAULT 4,

    is_active BOOLEAN NOT NULL DEFAULT FALSE,

    UNIQUE KEY uq_challenges_code (code),

    CONSTRAINT ck_challenges_difficulty
        CHECK (required_difficulty BETWEEN 1 AND 3),
    CONSTRAINT ck_challenges_qualification
        CHECK (required_unique_correct > 0),
    CONSTRAINT ck_challenges_question_count
        CHECK (question_count BETWEEN 1 AND 20),
    CONSTRAINT ck_challenges_pass
        CHECK (correct_to_pass BETWEEN 1 AND question_count),
    CONSTRAINT ck_challenges_active
        CHECK (is_active IN (0, 1)),

    CONSTRAINT fk_challenges_topic
        FOREIGN KEY (topic_id)
        REFERENCES topics (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE challenge_questions (
    challenge_id INT UNSIGNED NOT NULL,
    question_id INT UNSIGNED NOT NULL,
    sort_order SMALLINT UNSIGNED NOT NULL,

    PRIMARY KEY (challenge_id, question_id),
    UNIQUE KEY uq_challenge_question_order (challenge_id, sort_order),

    CONSTRAINT ck_challenge_question_order CHECK (sort_order > 0),

    CONSTRAINT fk_challenge_questions_challenge
        FOREIGN KEY (challenge_id)
        REFERENCES challenges (id) ON DELETE RESTRICT,

    CONSTRAINT fk_challenge_questions_question
        FOREIGN KEY (question_id)
        REFERENCES questions (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE challenge_runs (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    challenge_id INT UNSIGNED NOT NULL,
    user_id INT UNSIGNED NOT NULL,

    -- Samma startanrop ska kunna skickas om utan att skapa en ny omgång.
    start_request_key CHAR(36)
        CHARACTER SET ascii COLLATE ascii_bin NOT NULL,

    -- Kopieras från challenges när omgången startas.
    question_count TINYINT UNSIGNED NOT NULL,
    correct_to_pass TINYINT UNSIGNED NOT NULL,

    status ENUM('in_progress', 'passed', 'failed', 'abandoned')
        NOT NULL DEFAULT 'in_progress',

    started_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    finished_at DATETIME(6) NULL,

    UNIQUE KEY uq_challenge_run_request (user_id, start_request_key),

    -- Används av den sammansatta främmande nyckeln i answer_attempts.
    UNIQUE KEY uq_challenge_run_owner (id, user_id),

    KEY ix_challenge_runs_progress (user_id, challenge_id, status),

    CONSTRAINT ck_challenge_run_count
        CHECK (question_count BETWEEN 1 AND 20),
    CONSTRAINT ck_challenge_run_pass
        CHECK (correct_to_pass BETWEEN 1 AND question_count),
    CONSTRAINT ck_challenge_run_finished
        CHECK (
            (status = 'in_progress' AND finished_at IS NULL)
            OR
            (
                status IN ('passed', 'failed', 'abandoned')
                AND finished_at IS NOT NULL
            )
        ),

    CONSTRAINT fk_challenge_runs_challenge
        FOREIGN KEY (challenge_id)
        REFERENCES challenges (id) ON DELETE RESTRICT,

    CONSTRAINT fk_challenge_runs_user
        FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE challenge_run_questions (
    challenge_run_id INT UNSIGNED NOT NULL,
    question_id INT UNSIGNED NOT NULL,
    sort_order TINYINT UNSIGNED NOT NULL,

    PRIMARY KEY (challenge_run_id, question_id),
    UNIQUE KEY uq_challenge_run_question_order
        (challenge_run_id, sort_order),

    CONSTRAINT ck_challenge_run_question_order
        CHECK (sort_order > 0),

    CONSTRAINT fk_challenge_run_questions_run
        FOREIGN KEY (challenge_run_id)
        REFERENCES challenge_runs (id) ON DELETE RESTRICT,

    CONSTRAINT fk_challenge_run_questions_question
        FOREIGN KEY (question_id)
        REFERENCES questions (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

ALTER TABLE answer_attempts
    ADD COLUMN challenge_run_id INT UNSIGNED NULL,

    -- Högst ett sparat svar per fråga i samma utmaningsomgång.
    ADD UNIQUE KEY uq_attempts_challenge_question
        (challenge_run_id, question_id),

    -- Svaret måste tillhöra samma användare som spelomgången.
    ADD CONSTRAINT fk_attempts_challenge_owner
        FOREIGN KEY (challenge_run_id, user_id)
        REFERENCES challenge_runs (id, user_id)
        ON DELETE RESTRICT,

    -- Frågan måste vara en av omgångens valda frågor.
    ADD CONSTRAINT fk_attempts_challenge_question
        FOREIGN KEY (challenge_run_id, question_id)
        REFERENCES challenge_run_questions (challenge_run_id, question_id)
        ON DELETE RESTRICT;
