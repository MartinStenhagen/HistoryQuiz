-- Kör efter schema.sql och challenge.sql.
USE historyQuizDb;

CREATE TABLE teacher_quizzes (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    teacher_id INT UNSIGNED NOT NULL,
    title VARCHAR(100) NOT NULL,
    description VARCHAR(500) NULL,
    topic_id INT UNSIGNED NOT NULL,
    difficulty TINYINT UNSIGNED NOT NULL,
    status ENUM('draft', 'published', 'archived') NOT NULL DEFAULT 'draft',
    published_at DATETIME(6) NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    KEY ix_teacher_quizzes_owner_status (teacher_id, status),
    CONSTRAINT ck_teacher_quizzes_difficulty CHECK (difficulty BETWEEN 1 AND 3),
    CONSTRAINT ck_teacher_quizzes_publication CHECK (
        (status = 'draft' AND published_at IS NULL)
        OR (status IN ('published', 'archived') AND published_at IS NOT NULL)
    ),
    CONSTRAINT fk_teacher_quizzes_teacher FOREIGN KEY (teacher_id)
        REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT fk_teacher_quizzes_topic FOREIGN KEY (topic_id)
        REFERENCES topics (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

ALTER TABLE questions
    ADD COLUMN quiz_id INT UNSIGNED NULL,
    ALGORITHM=INSTANT;

ALTER TABLE questions
    ADD KEY ix_questions_quiz_status (quiz_id, status),
    ALGORITHM=INPLACE;

SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE questions
    ADD CONSTRAINT fk_questions_teacher_quiz FOREIGN KEY (quiz_id)
        REFERENCES teacher_quizzes (id) ON DELETE RESTRICT,
    ALGORITHM=INPLACE;

SET FOREIGN_KEY_CHECKS = 1;
