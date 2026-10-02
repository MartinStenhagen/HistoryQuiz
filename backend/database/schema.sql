SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci;
SET time_zone = '+00:00';

CREATE TABLE roles (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL,
    UNIQUE KEY uq_roles_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE users (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_id INT UNSIGNED NOT NULL,
    username VARCHAR(64) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    UNIQUE KEY uq_users_username (username),
    CONSTRAINT ck_users_active CHECK (is_active IN (0, 1)),
    CONSTRAINT fk_users_role FOREIGN KEY (role_id)
        REFERENCES roles (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE topics (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    UNIQUE KEY uq_topics_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE questions (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    topic_id INT UNSIGNED NOT NULL,
    question_text TEXT NOT NULL,
    explanation TEXT NOT NULL,
    difficulty TINYINT UNSIGNED NOT NULL DEFAULT 1,
    status ENUM('draft', 'published', 'archived') NOT NULL DEFAULT 'draft',
    published_at DATETIME(6) NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    KEY ix_questions_topic_status (topic_id, status),
    CONSTRAINT ck_questions_difficulty CHECK (difficulty BETWEEN 1 AND 3),
    CONSTRAINT ck_questions_publication CHECK (
        (status = 'draft' AND published_at IS NULL)
        OR (status IN ('published', 'archived') AND published_at IS NOT NULL)
    ),
    CONSTRAINT fk_questions_topic FOREIGN KEY (topic_id)
        REFERENCES topics (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE answer_options (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    question_id INT UNSIGNED NOT NULL,
    option_text VARCHAR(500) NOT NULL,
    sort_order TINYINT UNSIGNED NOT NULL,
    is_correct BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE KEY uq_options_position (question_id, sort_order),
    -- Explicit unik nyckel for svarsforsokets sammansatta frammande nyckel.
    UNIQUE KEY uq_options_question_id (question_id, id),
    CONSTRAINT ck_options_position CHECK (sort_order > 0),
    CONSTRAINT ck_options_correct CHECK (is_correct IN (0, 1)),
    CONSTRAINT fk_options_question FOREIGN KEY (question_id)
        REFERENCES questions (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE answer_attempts (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    question_id INT UNSIGNED NOT NULL,
    selected_option_id INT UNSIGNED NOT NULL,
    is_correct BOOLEAN NOT NULL,
    request_key CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    answered_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    UNIQUE KEY uq_attempts_request (user_id, request_key),
    KEY ix_attempts_user_order (user_id, id),
    KEY ix_attempts_user_question (user_id, question_id),
    KEY ix_attempts_question_option (question_id, selected_option_id),
    CONSTRAINT ck_attempts_correct CHECK (is_correct IN (0, 1)),
    CONSTRAINT fk_attempts_user FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT fk_attempts_question FOREIGN KEY (question_id)
        REFERENCES questions (id) ON DELETE RESTRICT,
    -- Hindrar att ett alternativ fran en ANNAN fraga registreras.
    CONSTRAINT fk_attempts_option FOREIGN KEY (question_id, selected_option_id)
        REFERENCES answer_options (question_id, id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE achievements (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(500) NOT NULL,
    metric ENUM('total_answers', 'total_correct', 'correct_streak', 'unique_answers_correct') NOT NULL,
    target_value INT UNSIGNED NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE KEY uq_achievements_code (code),
    CONSTRAINT ck_achievements_target CHECK (target_value > 0),
    CONSTRAINT ck_achievements_active CHECK (is_active IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE user_achievements (
    user_id INT UNSIGNED NOT NULL,
    achievement_id INT UNSIGNED NOT NULL,
    awarded_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (user_id, achievement_id),
    CONSTRAINT fk_user_achievements_user FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT fk_user_achievements_achievement FOREIGN KEY (achievement_id)
        REFERENCES achievements (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- En vy beraknar statistik fran historiken; inga manuella raknare behovs.
-- Anvandare utan svar far 0 i alla raknefalten och NULL i accuracy_percent.
CREATE VIEW v_user_statistics AS
SELECT
    u.id AS user_id,
    COUNT(a.id) AS total_answers,
    COALESCE(SUM(a.is_correct), 0) AS total_correct,
    COUNT(a.id) - COALESCE(SUM(a.is_correct), 0) AS total_wrong,
    COUNT(DISTINCT a.question_id) AS unique_questions_answered,
    -- Varje fraga raknas en gang om eleven nagon gang har svarat ratt pa den.
    COUNT(DISTINCT CASE WHEN a.is_correct = 1 THEN a.question_id END)
        AS unique_answers_correct,
    ROUND(100.0 * SUM(a.is_correct) / NULLIF(COUNT(a.id), 0), 1)
        AS accuracy_percent
FROM users AS u
LEFT JOIN answer_attempts AS a ON a.user_id = u.id
GROUP BY u.id;

INSERT INTO roles (code) VALUES ('student'), ('teacher'), ('admin');

INSERT INTO achievements (code, name, description, metric, target_value) VALUES
    ('FIRST_ANSWER', 'Första steget', 'Svara på din första fråga.', 'total_answers', 1),
    ('TEN_CORRECT', 'Historiekännaren', 'Svara rätt tio gånger totalt.', 'total_correct', 10),
    ('TEN_UNIQUE_CORRECT', 'Historieutforskaren', 'Svara rätt på tio olika frågor.', 'unique_answers_correct', 10),
    ('THREE_IN_A_ROW', 'Tre i rad', 'Svara rätt tre gånger i följd.', 'correct_streak', 3);

-- Inga anvandare eller lösenord skapas av detta skript.
-- Node.js måste uppratthalla publiceringsregler, behörigheter och rättning.
