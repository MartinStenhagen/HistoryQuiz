-- seed.sql
-- Kör en gång efter schema.sql mot tomma tabeller.
-- Initieringen väljer databas och hanterar transaktionen.


-- Roller
-- Student har ID 1 eftersom teacherService använder detta ID.

INSERT INTO roles (id, code) VALUES
    (1, 'student'),
    (2, 'teacher'),
    (3, 'admin');


-- Achievements

INSERT INTO achievements
    (code, name, description, metric, target_value, is_active)
VALUES
    (
        'FIRST_ANSWER',
        'Första steget',
        'Svara på din första fråga.',
        'total_answers',
        1,
        1
    ),
    (
        'TEN_CORRECT',
        'Historiekännaren',
        'Svara rätt tio gånger totalt.',
        'total_correct',
        10,
        1
    ),
    (
        'TEN_UNIQUE_CORRECT',
        'Historieutforskaren',
        'Svara rätt på tio olika frågor.',
        'unique_answers_correct',
        10,
        1
    ),
    (
        'THREE_IN_A_ROW',
        'Tre i rad',
        'Svara rätt tre gånger i följd.',
        'correct_streak',
        3,
        1
    ),
    (
        'HISTORICAL_CHALLENGER',
        'Caesars utmanare',
        'Klara Caesars utmaning.',
        'caesar_challenge_completed',
        1,
        1
    );


-- Ämnen

INSERT INTO topics (name, description)
VALUES ('Andra världskriget', 'Frågor om andra världskriget.');
SET @ww2_topic_id = LAST_INSERT_ID();

INSERT INTO topics (name, description)
VALUES (
    'Romarriket',
    'Frågor om Romarrikets kejsare, språk och historia.'
);
SET @roman_topic_id = LAST_INSERT_ID();

INSERT INTO topics (name, description)
VALUES (
    'Forntida Egypten',
    'Frågor om det forntida Egyptens historia'
);
SET @egypt_topic_id = LAST_INSERT_ID();

INSERT INTO topics (name, description)
VALUES ('Vikingatiden', 'Frågor om vikingarnas liv och resor');
SET @viking_topic_id = LAST_INSERT_ID();

INSERT INTO topics (name, description)
VALUES (
    'Sveriges historia',
    'Frågor om viktiga händelser i Sveriges historia'
);
SET @sweden_topic_id = LAST_INSERT_ID();


-- Caesars utmaning
-- Kvalificering: fem olika rätt besvarade vanliga frågor
-- om Romarriket på svårighetsgrad 3.
-- Utmaningen består av fem frågor och kräver fyra rätt.

INSERT INTO challenges (
    code,
    name,
    character_name,
    character_key,
    topic_id,
    required_difficulty,
    required_unique_correct,
    question_count,
    correct_to_pass,
    is_active
)
VALUES (
    'CAESAR_CHALLENGE',
    'Caesars utmaning',
    'Julius Caesar',
    'caesar',
    @roman_topic_id,
    3,
    5,
    5,
    4,
    1
);
SET @caesar_challenge_id = LAST_INSERT_ID();


-- Andra världskriget: 15 frågor

-- WW2_01
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @ww2_topic_id, 'WW2_01', 'regular',
    'Vilken term brukar man använda för att beskriva första dagen av landstigningarna i Normandie den 6 juni 1944?',
    'Termen Dagen D användes ursprungligen av de allierande under planeringsfasen innan det fanns ett bestämt datum.',
    1
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Den stora dagen', 1, 0),
    (@question_id, 'VE-Day', 2, 0),
    (@question_id, 'Dagen D', 3, 1),
    (@question_id, 'Landstigningen', 4, 0);

-- WW2_02
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @ww2_topic_id, 'WW2_02', 'regular',
    'Vilket land invaderade Tyskland den 1 september 1939?',
    'Tyskland invaderade Polen den 1 september 1939. Invasionen markerar början på andra världskriget i Europa.',
    1
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Frankrike', 1, 0),
    (@question_id, 'Polen', 2, 1),
    (@question_id, 'Norge', 3, 0),
    (@question_id, 'Grekland', 4, 0);

-- WW2_03
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @ww2_topic_id, 'WW2_03', 'regular',
    'Vad heter Storbritanniens flygvapen, som försvarade landet under slaget om Storbritannien 1940?',
    'Royal Air Force, förkortat RAF, försvarade Storbritannien mot det tyska flygvapnet Luftwaffe under slaget om Storbritannien 1940.',
    1
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Royal Air Force', 1, 1),
    (@question_id, 'Luftwaffe', 2, 0),
    (@question_id, 'Royal Navy', 3, 0),
    (@question_id, 'Wehrmacht', 4, 0);

-- WW2_04
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @ww2_topic_id, 'WW2_04', 'regular',
    'I vilket land utkämpades det andra slaget vid El Alamein 1942?',
    'Det andra slaget vid El Alamein utkämpades i Egypten mellan den 23 oktober och den 4 november 1942.',
    2
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Italien', 1, 0),
    (@question_id, 'Frankrike', 2, 0),
    (@question_id, 'Egypten', 3, 1),
    (@question_id, 'Polen', 4, 0);

-- WW2_05
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @ww2_topic_id, 'WW2_05', 'regular',
    'Vilket år tog andra världskriget slut i Europa?',
    'Kriget i Europa avslutades i maj 1945 efter Tysklands kapitulation.',
    1
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, '1940', 1, 0),
    (@question_id, '1942', 2, 0),
    (@question_id, '1944', 3, 0),
    (@question_id, '1945', 4, 1);

-- WW2_06
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @ww2_topic_id, 'WW2_06', 'regular',
    'Vilket år började andra världskriget?',
    'Andra världskriget började 1939 när Tyskland invaderade Polen.',
    1
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, '1935', 1, 0),
    (@question_id, '1939', 2, 1),
    (@question_id, '1941', 3, 0),
    (@question_id, '1945', 4, 0);

-- WW2_07
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @ww2_topic_id, 'WW2_07', 'regular',
    'Vilket land invaderade Tyskland 1939?',
    'Tyskland invaderade Polen den 1 september 1939.',
    1
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Frankrike', 1, 0),
    (@question_id, 'Danmark', 2, 0),
    (@question_id, 'Polen', 3, 1),
    (@question_id, 'Norge', 4, 0);

-- WW2_08
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @ww2_topic_id, 'WW2_08', 'regular',
    'Vilket år tog kriget slut i Europa?',
    'Tyskland kapitulerade i maj 1945.',
    1
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, '1943', 1, 0),
    (@question_id, '1944', 2, 0),
    (@question_id, '1945', 3, 1),
    (@question_id, '1946', 4, 0);

-- WW2_09
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @ww2_topic_id, 'WW2_09', 'regular',
    'Vad kallades landstigningen i Normandie den 6 juni 1944?',
    'Operation Overlord var de allierades operation för landstigningen i Normandie, vars första dag kallas Dagen D.',
    1
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Operation Barbarossa', 1, 0),
    (@question_id, 'Dagen D', 2, 1),
    (@question_id, 'Operation Torch', 3, 0),
    (@question_id, 'Operation Market Garden', 4, 0);

-- WW2_10
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @ww2_topic_id, 'WW2_10', 'regular',
    'Vem var Storbritanniens premiärminister under stora delar av kriget?',
    'Winston Churchill blev premiärminister 1940.',
    1
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Neville Chamberlain', 1, 0),
    (@question_id, 'Winston Churchill', 2, 1),
    (@question_id, 'Charles de Gaulle', 3, 0),
    (@question_id, 'Franklin D. Roosevelt', 4, 0);

-- WW2_11
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @ww2_topic_id, 'WW2_11', 'regular',
    'Vilka länder var bland de viktigaste allierade under kriget?',
    'Storbritannien, Sovjetunionen och USA var centrala allierade mot axelmakterna.',
    2
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Tyskland, Italien och Japan', 1, 0),
    (@question_id, 'Storbritannien, USA och Sovjetunionen', 2, 1),
    (@question_id, 'Spanien, Portugal och Schweiz', 3, 0),
    (@question_id, 'Sverige, Norge och Finland', 4, 0);

-- WW2_12
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @ww2_topic_id, 'WW2_12', 'regular',
    'Vad kallades Nazitysklands politiska ledare?',
    'Adolf Hitler var Nazitysklands diktator.',
    1
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Benito Mussolini', 1, 0),
    (@question_id, 'Joseph Stalin', 2, 0),
    (@question_id, 'Adolf Hitler', 3, 1),
    (@question_id, 'Winston Churchill', 4, 0);

-- WW2_13
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @ww2_topic_id, 'WW2_13', 'regular',
    'Vilket land attackerade Pearl Harbor 1941?',
    'Japan attackerade den amerikanska flottbasen Pearl Harbor den 7 december 1941.',
    2
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Italien', 1, 0),
    (@question_id, 'Japan', 2, 1),
    (@question_id, 'Tyskland', 3, 0),
    (@question_id, 'Sovjetunionen', 4, 0);

-- WW2_14
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @ww2_topic_id, 'WW2_14', 'regular',
    'Vad var Förintelsen?',
    'Förintelsen var Nazitysklands systematiska förföljelse och mord på sex miljoner judar, samt förföljelse och mord på andra grupper.',
    2
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'En fredskonferens', 1, 0),
    (@question_id, 'En militärallians', 2, 0),
    (@question_id, 'Nazisternas folkmord på Europas judar', 3, 1),
    (@question_id, 'Ett fredsavtal', 4, 0);

-- WW2_15
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @ww2_topic_id, 'WW2_15', 'regular',
    'Vilka två japanska städer utsattes för amerikanska atombomber 1945?',
    'Atombomber fälldes över Hiroshima den 6 augusti och Nagasaki den 9 augusti 1945.',
    2
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Tokyo och Kyoto', 1, 0),
    (@question_id, 'Hiroshima och Nagasaki', 2, 1),
    (@question_id, 'Osaka och Kobe', 3, 0),
    (@question_id, 'Sapporo och Yokohama', 4, 0);


-- Romarriket: 10 vanliga frågor

-- ROM_01
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @roman_topic_id, 'ROM_01', 'regular',
    'Vad hette Romarrikets första kejsare?',
    'Augustus räknas som Romarrikets första kejsare. Han hette tidigare Octavianus och fick namnet Augustus år 27 f.Kr.',
    1
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Julius Caesar', 1, 0),
    (@question_id, 'Augustus', 2, 1),
    (@question_id, 'Nero', 3, 0),
    (@question_id, 'Konstantin', 4, 0);

-- ROM_02
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @roman_topic_id, 'ROM_02', 'regular',
    'Vilken stad var Romarrikets ursprungliga huvudstad?',
    'Rom var rikets ursprungliga huvudstad och gav Romarriket dess namn.',
    1
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Aten', 1, 0),
    (@question_id, 'Alexandria', 2, 0),
    (@question_id, 'Kartago', 3, 0),
    (@question_id, 'Rom', 4, 1);

-- ROM_03
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @roman_topic_id, 'ROM_03', 'regular',
    'Vilket språk talades av romarna och blev grunden för bland annat italienska, franska och spanska?',
    'Latin talades av romarna. De romanska språken, däribland italienska, franska och spanska, utvecklades ur det talade latinet.',
    1
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Latin', 1, 1),
    (@question_id, 'Grekiska', 2, 0),
    (@question_id, 'Persiska', 3, 0),
    (@question_id, 'Egyptiska', 4, 0);

-- ROM_04
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @roman_topic_id, 'ROM_04', 'regular',
    'Vad heter den stora amfiteatern i Rom där bland annat gladiatorspel hölls?',
    'Colosseum är en amfiteater i Rom som användes för bland annat gladiatorspel och andra offentliga skådespel.',
    1
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Pantheon', 1, 0),
    (@question_id, 'Forum Romanum', 2, 0),
    (@question_id, 'Colosseum', 3, 1),
    (@question_id, 'Circus Maximus', 4, 0);

-- ROM_05
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @roman_topic_id, 'ROM_05', 'regular',
    'Vilket år brukar anges som året då Västrom föll?',
    'År 476 e.Kr. avsattes kejsaren Romulus Augustulus. Händelsen brukar räknas som slutet på Västrom, medan Östrom levde vidare.',
    2
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, '1066 e.Kr.', 1, 0),
    (@question_id, '1453 e.Kr.', 2, 0),
    (@question_id, '800 e.Kr.', 3, 0),
    (@question_id, '476 e.Kr.', 4, 1);

-- ROM_L3_01
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @roman_topic_id, 'ROM_L3_01', 'regular',
    'Varför hade den romerska republiken två konsuler?',
    'De delade makten och kunde stoppa varandras beslut.',
    3
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'En styrde bara på natten', 1, 0),
    (@question_id, 'För att begränsa en ensam ledares makt', 2, 1),
    (@question_id, 'De styrde varsin planet', 3, 0),
    (@question_id, 'En bestämde bara över maten', 4, 0);

-- ROM_L3_02
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @roman_topic_id, 'ROM_L3_02', 'regular',
    'Hur länge varade en konsuls vanliga ämbetsperiod?',
    'Konsuler valdes normalt för ett år.',
    3
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'En månad', 1, 0),
    (@question_id, 'Tio år', 2, 0),
    (@question_id, 'Ett år', 3, 1),
    (@question_id, 'Hela livet', 4, 0);

-- ROM_L3_03
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @roman_topic_id, 'ROM_L3_03', 'regular',
    'Vilken grupp skulle folktribunerna företräda?',
    'Folktribunerna företrädde plebejerna.',
    3
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Plebejerna', 1, 1),
    (@question_id, 'Bara kungafamiljen', 2, 0),
    (@question_id, 'Bara utländska kungar', 3, 0),
    (@question_id, 'Bara generalerna', 4, 0);

-- ROM_L3_04
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @roman_topic_id, 'ROM_L3_04', 'regular',
    'Vilken uppgift hade senaten under republiken?',
    'Senaten gav råd och hade stort inflytande över statens angelägenheter.',
    3
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Att utbilda alla gladiatorer', 1, 0),
    (@question_id, 'Att välja faraoner', 2, 0),
    (@question_id, 'Att styra de grekiska gudarna', 3, 0),
    (@question_id, 'Att ge råd om hur staten skulle styras', 4, 1);

-- ROM_L3_05
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @roman_topic_id, 'ROM_L3_05', 'regular',
    'Vilket styrelseskick hade Rom mellan kungatiden och kejsartiden?',
    'Under denna period var Rom en republik.',
    3
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Absolut kungadöme', 1, 0),
    (@question_id, 'Republik', 2, 1),
    (@question_id, 'Faraoniskt rike', 3, 0),
    (@question_id, 'Vikingating', 4, 0);


-- Caesars utmaning: 5 frågor

-- CAESAR_01
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @roman_topic_id, 'CAESAR_01', 'challenge',
    'Vilken titel hade Julius Caesar mot slutet av sitt liv?',
    'Caesar utsågs till diktator på livstid.',
    3
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Farao', 1, 0),
    (@question_id, 'Diktator', 2, 1),
    (@question_id, 'Vikingakung', 3, 0),
    (@question_id, 'Påve', 4, 0);

INSERT INTO challenge_questions (challenge_id, question_id, sort_order)
VALUES (@caesar_challenge_id, @question_id, 1);

-- CAESAR_02
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @roman_topic_id, 'CAESAR_02', 'challenge',
    'Vem adopterade Caesar genom sitt testamente?',
    'Octavianus adopterades genom Caesars testamente och blev senare Augustus.',
    3
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Nero', 1, 0),
    (@question_id, 'Hannibal', 2, 0),
    (@question_id, 'Octavianus', 3, 1),
    (@question_id, 'Romulus', 4, 0);

INSERT INTO challenge_questions (challenge_id, question_id, sort_order)
VALUES (@caesar_challenge_id, @question_id, 2);

-- CAESAR_03
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @roman_topic_id, 'CAESAR_03', 'challenge',
    'Vilken månad har fått sitt namn efter Julius Caesar?',
    'Månaden juli fick sitt namn till Caesars ära.',
    3
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Juli', 1, 1),
    (@question_id, 'Mars', 2, 0),
    (@question_id, 'September', 3, 0),
    (@question_id, 'December', 4, 0);

INSERT INTO challenge_questions (challenge_id, question_id, sort_order)
VALUES (@caesar_challenge_id, @question_id, 3);

-- CAESAR_04
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @roman_topic_id, 'CAESAR_04', 'challenge',
    'Vad kallas kalendern som infördes genom Caesars kalenderreform?',
    'Den kallas den julianska kalendern.',
    3
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Vikingakalendern', 1, 0),
    (@question_id, 'Den gregorianska kalendern', 2, 0),
    (@question_id, 'Månkalendern', 3, 0),
    (@question_id, 'Den julianska kalendern', 4, 1);

INSERT INTO challenge_questions (challenge_id, question_id, sort_order)
VALUES (@caesar_challenge_id, @question_id, 4);

-- CAESAR_05
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @roman_topic_id, 'CAESAR_05', 'challenge',
    'Vilket år började Caesars nya kalender användas?',
    'Den julianska kalendern började användas år 45 f.Kr.',
    3
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, '476 e.Kr.', 1, 0),
    (@question_id, '45 f.Kr.', 2, 1),
    (@question_id, '1523 e.Kr.', 3, 0),
    (@question_id, '27 f.Kr.', 4, 0);

INSERT INTO challenge_questions (challenge_id, question_id, sort_order)
VALUES (@caesar_challenge_id, @question_id, 5);


-- Forntida Egypten: 3 frågor

-- EGYPT_01
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @egypt_topic_id, 'EGYPT_01', 'regular',
    'Vilken flod var viktig för det forntida Egypten?',
    'Nilen gav vatten och bördig jord till jordbruket.',
    1
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Nilen', 1, 1),
    (@question_id, 'Amazonas', 2, 0),
    (@question_id, 'Donau', 3, 0),
    (@question_id, 'Rhen', 4, 0);

-- EGYPT_02
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @egypt_topic_id, 'EGYPT_02', 'regular',
    'Vad kallades de egyptiska bildtecknen?',
    'De egyptiska bildtecknen kallas hieroglyfer.',
    2
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Kilskrift', 1, 0),
    (@question_id, 'Hieroglyfer', 2, 1),
    (@question_id, 'Runor', 3, 0),
    (@question_id, 'Alfabetisk skrift', 4, 0);

-- EGYPT_03
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @egypt_topic_id, 'EGYPT_03', 'regular',
    'Vilken egyptisk farao förknippas med graven som hittades nästan orörd 1922?',
    'Tutankhamons grav upptäcktes av Howard Carter och hans team.',
    3
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Ramses II', 1, 0),
    (@question_id, 'Kleopatra', 2, 0),
    (@question_id, 'Tutankhamon', 3, 1),
    (@question_id, 'Akhenaton', 4, 0);


-- Vikingatiden: 3 frågor

-- VIKING_01
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @viking_topic_id, 'VIKING_01', 'regular',
    'Vad använde vikingarna främst för att resa över havet?',
    'Vikingarna använde bland annat långskepp.',
    1
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Långskepp', 1, 1),
    (@question_id, 'Ångbåtar', 2, 0),
    (@question_id, 'Ubåtar', 3, 0),
    (@question_id, 'Tåg', 4, 0);

-- VIKING_02
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @viking_topic_id, 'VIKING_02', 'regular',
    'Vad kallades vikingarnas gamla nordiska skriftsymboler?',
    'Runor användes för att skriva i det fornnordiska samhället.',
    2
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Hieroglyfer', 1, 0),
    (@question_id, 'Runor', 2, 1),
    (@question_id, 'Latinska bokstäver', 3, 0),
    (@question_id, 'Kilskrift', 4, 0);

-- VIKING_03
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @viking_topic_id, 'VIKING_03', 'regular',
    'Vilken vikingaledare förknippas med upptäckten av Grönland?',
    'Erik den röde förknippas med den nordiska bosättningen på Grönland.',
    3
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Harald Blåtand', 1, 0),
    (@question_id, 'Erik den röde', 2, 1),
    (@question_id, 'Olof Skötkonung', 3, 0),
    (@question_id, 'Gustav Vasa', 4, 0);


-- Sveriges historia: 3 frågor

-- SWE_01
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @sweden_topic_id, 'SWE_01', 'regular',
    'Vilken världsdel ligger Sverige i?',
    'Sverige ligger i Europa.',
    1
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, 'Europa', 1, 1),
    (@question_id, 'Afrika', 2, 0),
    (@question_id, 'Asien', 3, 0),
    (@question_id, 'Sydamerika', 4, 0);

-- SWE_02
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @sweden_topic_id, 'SWE_02', 'regular',
    'Vilket år blev Gustav Vasa kung av Sverige?',
    'Gustav Vasa blev kung år 1523.',
    2
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, '1397', 1, 0),
    (@question_id, '1523', 2, 1),
    (@question_id, '1611', 3, 0),
    (@question_id, '1809', 4, 0);

-- SWE_03
INSERT INTO questions
    (topic_id, question_code, question_kind, question_text, explanation, difficulty)
VALUES (
    @sweden_topic_id, 'SWE_03', 'regular',
    'Vilket år upplöstes unionen mellan Sverige och Norge?',
    'Unionen mellan Sverige och Norge upplöstes 1905.',
    3
);
SET @question_id = LAST_INSERT_ID();

INSERT INTO answer_options (question_id, option_text, sort_order, is_correct)
VALUES
    (@question_id, '1814', 1, 0),
    (@question_id, '1865', 2, 0),
    (@question_id, '1905', 3, 1),
    (@question_id, '1918', 4, 0);


-- Konton, svar, spelomgångar och tilldelade achievements skapas av appen
 