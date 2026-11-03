SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci;
SET time_zone = '+00:00';

-- Roller och användare

CREATE TABLE IF NOT EXISTS roles (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL,

    UNIQUE KEY uq_roles_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS users (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_id INT UNSIGNED NOT NULL,
    username VARCHAR(64) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255)
        CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    UNIQUE KEY uq_users_username (username),

    CONSTRAINT fk_users_role
        FOREIGN KEY (role_id)
        REFERENCES roles (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- Ämnen, frågor och svarsalternativ

CREATE TABLE IF NOT EXISTS topics (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT NULL,

    UNIQUE KEY uq_topics_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS questions (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    topic_id INT UNSIGNED NOT NULL,
    question_code VARCHAR(64) NULL,
    question_kind ENUM('regular', 'challenge')
        NOT NULL DEFAULT 'regular',
    question_text TEXT NOT NULL,
    explanation TEXT NOT NULL,
    difficulty TINYINT UNSIGNED NOT NULL DEFAULT 1,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    UNIQUE KEY uq_questions_code (question_code),
    KEY ix_questions_selection (
        topic_id,
        question_kind,
        difficulty
    ),

    CONSTRAINT ck_questions_difficulty
        CHECK (difficulty BETWEEN 1 AND 3),

    CONSTRAINT fk_questions_topic
        FOREIGN KEY (topic_id)
        REFERENCES topics (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS answer_options (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    question_id INT UNSIGNED NOT NULL,
    option_text VARCHAR(500) NOT NULL,
    sort_order TINYINT UNSIGNED NOT NULL,
    is_correct BOOLEAN NOT NULL DEFAULT FALSE,

    UNIQUE KEY uq_options_position (question_id, sort_order),

    -- Används av den sammansatta relationen i answer_attempts.
    UNIQUE KEY uq_options_question_id (question_id, id),

    CONSTRAINT ck_options_position
        CHECK (sort_order > 0),

    CONSTRAINT ck_options_correct
        CHECK (is_correct IN (0, 1)),

    CONSTRAINT fk_options_question
        FOREIGN KEY (question_id)
        REFERENCES questions (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- Achievements

CREATE TABLE IF NOT EXISTS achievements (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(500) NOT NULL,
    metric ENUM(
        'total_answers',
        'total_correct',
        'correct_streak',
        'unique_answers_correct',
        'caesar_challenge_completed'
    ) NOT NULL,
    target_value INT UNSIGNED NOT NULL,

    UNIQUE KEY uq_achievements_code (code),

    CONSTRAINT ck_achievements_target
        CHECK (target_value > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS user_achievements (
    user_id INT UNSIGNED NOT NULL,
    achievement_id INT UNSIGNED NOT NULL,
    awarded_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    PRIMARY KEY (user_id, achievement_id),

    CONSTRAINT fk_user_achievements_user
        FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE RESTRICT,

    CONSTRAINT fk_user_achievements_achievement
        FOREIGN KEY (achievement_id)
        REFERENCES achievements (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- Inloggningssessioner

CREATE TABLE IF NOT EXISTS sessions (
    session_id VARCHAR(128)
        CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
    expires INT UNSIGNED NOT NULL,
    data MEDIUMTEXT
        CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,

    PRIMARY KEY (session_id),
    KEY ix_sessions_expires (expires)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- Utmaningarnas definitioner och tillgängliga frågor

CREATE TABLE IF NOT EXISTS challenges (
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

    UNIQUE KEY uq_challenges_code (code),

    CONSTRAINT ck_challenges_difficulty
        CHECK (required_difficulty BETWEEN 1 AND 3),

    CONSTRAINT ck_challenges_qualification
        CHECK (required_unique_correct > 0),

    CONSTRAINT ck_challenges_question_count
        CHECK (question_count BETWEEN 1 AND 20),

    CONSTRAINT ck_challenges_pass
        CHECK (correct_to_pass BETWEEN 1 AND question_count),

    CONSTRAINT fk_challenges_topic
        FOREIGN KEY (topic_id)
        REFERENCES topics (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS challenge_questions (
    challenge_id INT UNSIGNED NOT NULL,
    question_id INT UNSIGNED NOT NULL,
    sort_order SMALLINT UNSIGNED NOT NULL,

    PRIMARY KEY (challenge_id, question_id),
    UNIQUE KEY uq_challenge_question_order (
        challenge_id,
        sort_order
    ),

    CONSTRAINT ck_challenge_question_order
        CHECK (sort_order > 0),

    CONSTRAINT fk_challenge_questions_challenge
        FOREIGN KEY (challenge_id)
        REFERENCES challenges (id) ON DELETE RESTRICT,

    CONSTRAINT fk_challenge_questions_question
        FOREIGN KEY (question_id)
        REFERENCES questions (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- Spelade utmaningsomgångar

CREATE TABLE IF NOT EXISTS challenge_runs (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    challenge_id INT UNSIGNED NOT NULL,
    user_id INT UNSIGNED NOT NULL,

    start_request_key CHAR(36)
        CHARACTER SET ascii COLLATE ascii_bin NOT NULL,

    -- Reglerna som gällde när omgången startades.
    question_count TINYINT UNSIGNED NOT NULL,
    correct_to_pass TINYINT UNSIGNED NOT NULL,

    status ENUM('in_progress', 'passed', 'failed', 'abandoned')
        NOT NULL DEFAULT 'in_progress',

    started_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    finished_at DATETIME(6) NULL,

    UNIQUE KEY uq_challenge_run_request (
        user_id,
        start_request_key
    ),
    UNIQUE KEY uq_challenge_run_owner (id, user_id),

    KEY ix_challenge_runs_progress (
        user_id,
        challenge_id,
        status
    ),

    CONSTRAINT ck_challenge_run_count
        CHECK (question_count BETWEEN 1 AND 20),

    CONSTRAINT ck_challenge_run_pass
        CHECK (correct_to_pass BETWEEN 1 AND question_count),

    CONSTRAINT ck_challenge_run_finished
        CHECK (
            (status = 'in_progress' AND finished_at IS NULL)
            OR (
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

CREATE TABLE IF NOT EXISTS challenge_run_questions (
    challenge_run_id INT UNSIGNED NOT NULL,
    question_id INT UNSIGNED NOT NULL,
    sort_order TINYINT UNSIGNED NOT NULL,

    PRIMARY KEY (challenge_run_id, question_id),
    UNIQUE KEY uq_challenge_run_question_order (
        challenge_run_id,
        sort_order
    ),

    CONSTRAINT ck_challenge_run_question_order
        CHECK (sort_order > 0),

    CONSTRAINT fk_challenge_run_questions_run
        FOREIGN KEY (challenge_run_id)
        REFERENCES challenge_runs (id) ON DELETE RESTRICT,

    CONSTRAINT fk_challenge_run_questions_question
        FOREIGN KEY (question_id)
        REFERENCES questions (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- Sparade svar från både vanliga quiz och utmaningar

CREATE TABLE IF NOT EXISTS answer_attempts (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    question_id INT UNSIGNED NOT NULL,
    selected_option_id INT UNSIGNED NOT NULL,
    is_correct BOOLEAN NOT NULL,

    request_key CHAR(36)
        CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    response_json JSON NULL,

    -- NULL betyder att svaret kommer från ett vanligt quiz.
    challenge_run_id INT UNSIGNED NULL,

    answered_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    UNIQUE KEY uq_attempts_request (user_id, request_key),
    UNIQUE KEY uq_attempts_challenge_question (
        challenge_run_id,
        question_id
    ),

    KEY ix_attempts_user_order (user_id, id),
    KEY ix_attempts_user_question (user_id, question_id),
    KEY ix_attempts_question_option (
        question_id,
        selected_option_id
    ),

    CONSTRAINT ck_attempts_correct
        CHECK (is_correct IN (0, 1)),

    CONSTRAINT fk_attempts_user
        FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE RESTRICT,

    CONSTRAINT fk_attempts_question
        FOREIGN KEY (question_id)
        REFERENCES questions (id) ON DELETE RESTRICT,

    -- Svarsalternativet måste tillhöra frågan.
    CONSTRAINT fk_attempts_option
        FOREIGN KEY (question_id, selected_option_id)
        REFERENCES answer_options (question_id, id)
        ON DELETE RESTRICT,

    -- Utmaningsomgången måste tillhöra användaren.
    CONSTRAINT fk_attempts_challenge_owner
        FOREIGN KEY (challenge_run_id, user_id)
        REFERENCES challenge_runs (id, user_id)
        ON DELETE RESTRICT,

    -- Frågan måste ingå i utmaningsomgången.
    CONSTRAINT fk_attempts_challenge_question
        FOREIGN KEY (challenge_run_id, question_id)
        REFERENCES challenge_run_questions (
            challenge_run_id,
            question_id
        )
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- Statistik beräknas från sparade svar.

CREATE OR REPLACE VIEW v_user_statistics AS
SELECT
    u.id AS user_id,
    COUNT(a.id) AS total_answers,
    COALESCE(SUM(a.is_correct), 0) AS total_correct,
    COUNT(a.id) - COALESCE(SUM(a.is_correct), 0) AS total_wrong,
    COUNT(DISTINCT a.question_id) AS unique_questions_answered,
    COUNT(
        DISTINCT CASE
            WHEN a.is_correct = 1 THEN a.question_id
        END
    ) AS unique_answers_correct,
    ROUND(
        100.0 * SUM(a.is_correct) / NULLIF(COUNT(a.id), 0),
        1
    ) AS accuracy_percent
FROM users AS u
LEFT JOIN answer_attempts AS a ON a.user_id = u.id
GROUP BY u.id;
