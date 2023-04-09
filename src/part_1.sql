-- CREATE DATABASE s21_SQL2_Info21
-- WITH 
-- OWNER = postgres
-- ENCODING = 'UTF8'
-- LC_COLLATE = 'en_US.UTF-8'
-- LC_CTYPE = 'en_US.UTF-8'
-- TABLESPACE = pg_default
-- CONNECTION LIMIT = -1;


CREATE TABLE IF NOT EXISTS peers (
    nickname varchar(50) PRIMARY KEY NOT NULL,
    birthday date NOT NULL
);
ALTER TABLE IF EXISTS public.peers OWNER to postgres;
INSERT INTO peers (nickname, birthday)
VALUES ('Leonardo_DiCaprio', '1996-01-01'),
    ('George_Clooney', '1996-01-02'),
    ('Sandra_Bullock', '1996-01-03'),
    ('Kate_Winslet', '1996-01-04'),
    ('Morgan_Freeman', '1996-01-05'),
    ('Penеlope_Cruz', '1996-01-06'),
    ('Clint_Eastwood', '1996-01-07'),
    ('Martin_Scorsese', '1996-01-08'),
    ('Anthony_Hopkins', '1996-01-09'),
    ('Natalie_Portman', '1996-01-10');
-- SELECT * FROM peers;
-- DROP TABLE IF EXISTS tasks CASCADE;
-- TRUNCATE TABLE tasks CASCADE;
CREATE TABLE IF NOT EXISTS tasks (
    title text PRIMARY KEY NOT NULL,
    parent_task text,
    max_xp integer NOT NULL,
    CONSTRAINT tasks_parent_task_fkey FOREIGN KEY (parent_task) REFERENCES tasks (title) ON UPDATE NO ACTION ON DELETE NO ACTION
);
ALTER TABLE IF EXISTS public.tasks OWNER to postgres;
INSERT INTO Tasks (title, parent_task, max_xp)
VALUES ('C2_SimpleBashUtils', NULL, 250),
    ('C3_s21_string+', 'C2_SimpleBashUtils', 500),
    ('C4_s21_math', 'C2_SimpleBashUtils', 300),
    ('C5_s21_decimal', 'C4_s21_math', 350),
    ('C6_s21_matrix', 'C5_s21_decimal', 200),
    ('C7_SmartCalc_v1.0', 'C6_s21_matrix', 500),
    ('C8_3DViewer_v1.0', 'C7_SmartCalc_v1.0', 750),
    ('DO1_Linux', 'C3_s21_string+', 300),
    ('DO2_Linux Network', 'DO1_Linux', 250),
    (
        'DO3_LinuxMonitoring v1.0',
        'DO2_Linux Network',
        350
    ),
    (
        'DO4_LinuxMonitoring v2.0',
        'DO3_LinuxMonitoring v1.0',
        350
    ),
    (
        'DO5_SimpleDocker',
        'DO3_LinuxMonitoring v1.0',
        300
    ),
    ('DO6_CICD', 'DO5_SimpleDocker', 300),
    ('CPP1_s21_matrix+', 'C8_3DViewer_v1.0', 300),
    ('CPP2_s21_containers', 'CPP1_s21_matrix+', 350),
    (
        'CPP3_SmartCalc_v2.0',
        'CPP2_s21_containers',
        600
    ),
    ('CPP4_3DViewer_v2.0', 'CPP3_SmartCalc_v2.0', 750),
    ('CPP5_3DViewer_v2.1', 'CPP4_3DViewer_v2.0', 600),
    ('CPP6_3DViewer_v2.2', 'CPP4_3DViewer_v2.0', 800),
    ('CPP7_MLP', 'CPP4_3DViewer_v2.0', 700),
    ('CPP8_PhotoLab_v1.0', 'CPP4_3DViewer_v2.0', 450),
    (
        'CPP9_MonitoringSystem',
        'CPP4_3DViewer_v2.0',
        1000
    ),
    ('A1_Maze', 'CPP4_3DViewer_v2.0', 300),
    ('A2_SimpleNavigator v1.0', 'A1_Maze', 400),
    ('A3_Parallels', 'A2_SimpleNavigator v1.0', 300),
    ('A4_Crypto', 'A2_SimpleNavigator v1.0', 350),
    ('A5_s21_memory', 'A2_SimpleNavigator v1.0', 400),
    (
        'A6_Transactions',
        'A2_SimpleNavigator v1.0',
        700
    ),
    (
        'A7_DNA Analyzer',
        'A2_SimpleNavigator v1.0',
        800
    ),
    (
        'A8_Algorithmic trading',
        'A2_SimpleNavigator v1.0',
        800
    ),
    ('SQL1_Bootcamp', 'C8_3DViewer_v1.0', 1500),
    ('SQL2_Info21 v1.0', 'SQL1_Bootcamp', 500),
    (
        'SQL3_RetailAnalitycs v1.0',
        'SQL2_Info21 v1.0',
        600
    );
-- SELECT * FROM tasks;
-- DROP TYPE IF EXISTS checkstatus CASCADE;
CREATE TYPE checkstatus AS ENUM ('Start', 'Success', 'Failure');
ALTER TYPE checkstatus OWNER TO postgres;
-- DROP TABLE IF EXISTS checks CASCADE;
-- TRUNCATE TABLE checks CASCADE;
CREATE TABLE IF NOT EXISTS checks (
    id serial PRIMARY KEY NOT NULL,
    peer varchar(50) NOT NULL,
    task text NOT NULL,
    date date,
    CONSTRAINT checks_peer_fkey FOREIGN KEY (peer) REFERENCES peers (nickname) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT checks_task_fkey FOREIGN KEY (task) REFERENCES tasks (title) ON UPDATE NO ACTION ON DELETE NO ACTION
);
ALTER TABLE IF EXISTS public.checks OWNER to postgres;
INSERT INTO Checks (peer, task, date)
VALUES (
        'Leonardo_DiCaprio',
        'C2_SimpleBashUtils',
        '2022-06-01'
    ),
    (
        'Leonardo_DiCaprio',
        'C2_SimpleBashUtils',
        '2022-06-06'
    ),
    ('George_Clooney', 'C4_s21_math', '2022-05-06'),
    ('Sandra_Bullock', 'C6_s21_matrix', '2022-07-16'),
    ('Sandra_Bullock', 'C6_s21_matrix', '2022-07-20'),
    ('Martin_Scorsese', 'DO1_Linux', '2022-06-16'),
    (
        'Natalie_Portman',
        'DO2_Linux Network',
        '2022-07-16'
    ),
    (
        'Leonardo_DiCaprio',
        'DO2_Linux Network',
        '2022-07-16'
    ),
    (
        'Leonardo_DiCaprio',
        'DO3_LinuxMonitoring v1.0',
        '2022-08-21'
    ),
    (
        'Anthony_Hopkins',
        'C5_s21_decimal',
        '2022-05-21'
    ),
    (
        'Leonardo_DiCaprio',
        'C3_s21_string+',
        '2022-06-06'
    ),
    ('Clint_Eastwood', 'C4_s21_math', '2022-07-08'),
    ('George_Clooney', 'C3_s21_string+', '2022-08-08'),
    ('Morgan_Freeman', 'DO1_Linux', '2022-06-01'),
    ('Kate_Winslet', 'C6_s21_matrix', '2022-10-10'),
    ('Penеlope_Cruz', 'DO1_Linux', '2022-07-07'),
    (
        'Leonardo_DiCaprio',
        'C2_SimpleBashUtils',
        '2022-06-07'
    );
-- SELECT * FROM checks;
-- DROP TABLE IF EXISTS p2p CASCADE;
-- TRUNCATE TABLE p2p CASCADE;
CREATE TABLE IF NOT EXISTS p2p (
    id serial PRIMARY KEY NOT NULL,
    "check" integer NOT NULL,
    checking_peer varchar(50) NOT NULL,
    "state" checkstatus NOT NULL,
    "time" time(2) without time zone NOT NULL,
    CONSTRAINT p2p_check_checking_peer_state_key UNIQUE ("check", checking_peer, state),
    CONSTRAINT p2p_check_fkey FOREIGN KEY ("check") REFERENCES checks (id) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT p2p_checking_peer_fkey FOREIGN KEY (checking_peer) REFERENCES peers (nickname) ON UPDATE NO ACTION ON DELETE NO ACTION
);
ALTER TABLE IF EXISTS p2p OWNER to postgres;
INSERT INTO P2P ("check", checking_peer, "state", time)
VALUES (1, 'George_Clooney', 'Start', '09:00:00'),
    (1, 'George_Clooney', 'Failure', '10:00:00'),
    (2, 'Sandra_Bullock', 'Start', '13:00:00'),
    (2, 'Sandra_Bullock', 'Success', '14:00:00'),
    (3, 'Leonardo_DiCaprio', 'Start', '22:00:00'),
    (3, 'Leonardo_DiCaprio', 'Success', '23:00:00'),
    (4, 'Penеlope_Cruz', 'Start', '15:00:00'),
    (4, 'Penеlope_Cruz', 'Success', '16:00:00'),
    (5, 'Natalie_Portman', 'Start', '14:00:00'),
    (5, 'Natalie_Portman', 'Success', '15:00:00'),
    (6, 'Morgan_Freeman', 'Start', '01:00:00'),
    (6, 'Morgan_Freeman', 'Success', '02:00:00'),
    (7, 'Martin_Scorsese', 'Start', '10:00:00'),
    (7, 'Martin_Scorsese', 'Success', '12:00:00'),
    (8, 'Anthony_Hopkins', 'Start', '12:00:00'),
    (8, 'Anthony_Hopkins', 'Success', '13:00:00'),
    (9, 'George_Clooney', 'Start', '12:00:00'),
    (9, 'George_Clooney', 'Success', '13:00:00'),
    (10, 'Kate_Winslet', 'Start', '19:00:00'),
    (11, 'Martin_Scorsese', 'Start', '15:00:00'),
    (11, 'Martin_Scorsese', 'Success', '15:01:00'),
    (12, 'Penеlope_Cruz', 'Start', '22:00:00'),
    (12, 'Penеlope_Cruz', 'Failure', '23:00:00'),
    (13, 'Natalie_Portman', 'Start', '22:00:00'),
    (13, 'Natalie_Portman', 'Success', '23:00:00'),
    (14, 'Leonardo_DiCaprio', 'Start', '22:00:00'),
    (14, 'Leonardo_DiCaprio', 'Success', '23:00:00'),
    (15, 'Penеlope_Cruz', 'Start', '04:00:00'),
    (15, 'Penеlope_Cruz', 'Success', '05:00:00'),
    (16, 'Clint_Eastwood', 'Start', '05:00:00'),
    (16, 'Clint_Eastwood', 'Failure', '06:00:00'),
    (17, 'Clint_Eastwood', 'Start', '05:00:00'),
    (17, 'Clint_Eastwood', 'Success', '06:00:00');
-- SELECT *
-- FROM p2p;
-- DROP TABLE IF EXISTS verter CASCADE;
-- TRUNCATE TABLE verter CASCADE;
CREATE TABLE IF NOT EXISTS verter (
    id serial PRIMARY KEY NOT NULL,
    "check" integer NOT NULL,
    "state" checkstatus NOT NULL,
    "time" time without time zone,
    CONSTRAINT verter_check_fkey FOREIGN KEY ("check") REFERENCES checks (id) ON UPDATE NO ACTION ON DELETE NO ACTION
);
ALTER TABLE IF EXISTS verter OWNER to postgres;
INSERT INTO Verter("check", "state", Time)
VALUES (2, 'Start', '13:01'),
    (2, 'Success', '13:02'),
    (3, 'Start', '23:01'),
    (3, 'Success', '23:02'),
    (4, 'Start', '16:01'),
    (4, 'Failure', '16:02'),
    (5, 'Start', '15:01'),
    (5, 'Success', '15:02'),
    (13, 'Start', '23:01'),
    (13, 'Success', '23:02'),
    (15, 'Start', '05:01'),
    (15, 'Failure', '05:02'),
    (17, 'Start', '06:01'),
    (17, 'Success', '06:02');
-- SELECT *
-- FROM verter;
-- DROP TABLE IF EXISTS recommendations CASCADE;
-- TRUNCATE TABLE recommendations CASCADE;
CREATE TABLE IF NOT EXISTS recommendations (
    id serial PRIMARY KEY NOT NULL,
    peer varchar (50) NOT NULL,
    recommendet_peer varchar(50) NOT NULL,
    CONSTRAINT recommendations_peer_fkey FOREIGN KEY (peer) REFERENCES peers (nickname) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT recommendations_recommendet_peer_fkey FOREIGN KEY (recommendet_peer) REFERENCES peers (nickname) ON UPDATE NO ACTION ON DELETE NO ACTION
);
ALTER TABLE IF EXISTS recommendations OWNER to postgres;
INSERT INTO Recommendations (peer, recommendet_peer)
VALUES ('Leonardo_DiCaprio', 'George_Clooney'),
    ('Leonardo_DiCaprio', 'Morgan_Freeman'),
    ('George_Clooney', 'Sandra_Bullock'),
    ('Penеlope_Cruz', 'Leonardo_DiCaprio'),
    ('Kate_Winslet', 'Penеlope_Cruz'),
    ('Kate_Winslet', 'Clint_Eastwood'),
    ('Martin_Scorsese', 'Kate_Winslet'),
    ('Clint_Eastwood', 'George_Clooney'),
    ('Anthony_Hopkins', 'Martin_Scorsese'),
    ('Anthony_Hopkins', 'Natalie_Portman');
-- SELECT * FROM Recommendations;	
-- DROP TABLE IF EXISTS xp CASCADE;
-- TRUNCATE TABLE xp CASCADE;
CREATE TABLE IF NOT EXISTS xp (
    id serial PRIMARY KEY NOT NULL,
    "check" integer NOT NULL,
    xp_amount integer,
    CONSTRAINT xp_check_fkey FOREIGN KEY ("check") REFERENCES checks (id) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT xp_xp_amount_check CHECK (xp_amount > 0)
);
ALTER TABLE IF EXISTS public.xp OWNER to postgres;
INSERT INTO XP ("check", xp_amount)
VALUES (2, 240),
    (3, 300),
    (5, 200),
    (6, 250),
    (7, 250),
    (8, 250),
    (9, 350),
    (10, 299),
    (17, 250);
--SELECT * FROM xp;	   
-- DROP TABLE IF EXISTS transferred_points CASCADE;
-- TRUNCATE TABLE transferred_points CASCADE;
CREATE TABLE IF NOT EXISTS transferred_points (
    id serial NOT NULL PRIMARY KEY,
    checking_peer varchar(50) NOT NULL,
    checked_peer varchar(50) NOT NULL,
    points_amount integer NOT NULL,
    CONSTRAINT transferred_points_checked_peer_fkey FOREIGN KEY (checked_peer) REFERENCES peers (nickname) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT transferred_points_checking_peer_fkey FOREIGN KEY (checking_peer) REFERENCES peers (nickname) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT transferred_points_check CHECK (checking_peer::text <> checked_peer::text)
);
ALTER TABLE IF EXISTS transferred_points OWNER to postgres;
INSERT INTO transferred_points(checking_peer, checked_peer, points_amount)
VALUES('George_Clooney', 'Leonardo_DiCaprio', 1),
    ('Leonardo_DiCaprio', 'George_Clooney', 2),
    ('Sandra_Bullock', 'Leonardo_DiCaprio', 3),
    ('Leonardo_DiCaprio', 'Sandra_Bullock', 5),
    ('Kate_Winslet', 'Leonardo_DiCaprio', 4),
    ('Leonardo_DiCaprio', 'Kate_Winslet', 0),
    ('Morgan_Freeman', 'Leonardo_DiCaprio', 2),
    ('Leonardo_DiCaprio', 'Morgan_Freeman', 3),
    ('Penеlope_Cruz', 'Leonardo_DiCaprio', 1),
    ('Leonardo_DiCaprio', 'Penеlope_Cruz', 2),
    ('Clint_Eastwood', 'Leonardo_DiCaprio', 9),
    ('Leonardo_DiCaprio', 'Clint_Eastwood', 1);
--SELECT * FROM transferred_points;
-- DROP TABLE IF EXISTS time_tracking CASCADE;
-- TRUNCATE TABLE time_tracking CASCADE;
CREATE TABLE IF NOT EXISTS time_tracking (
    id serial NOT NULL PRIMARY KEY,
    peer varchar(50),
    date date,
    "time" time without time zone,
    state integer,
    CONSTRAINT time_tracking_peer_fkey FOREIGN KEY (peer) REFERENCES peers (nickname) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT time_tracking_state_check CHECK (state = ANY (ARRAY [1, 2]))
);
ALTER TABLE IF EXISTS time_tracking OWNER to postgres;
INSERT INTO time_tracking(peer, date, time, "state")
VALUES ('Leonardo_DiCaprio', '2022-05-02', '08:00:00', 1),
    ('Leonardo_DiCaprio', '2022-05-02', '18:00:00', 2),
    ('George_Clooney', '2022-05-02', '18:30:00', 1),
    ('George_Clooney', '2022-05-02', '23:30:00', 2),
    ('Leonardo_DiCaprio', '2022-05-02', '18:10:00', 1),
    ('Leonardo_DiCaprio', '2022-05-02', '21:00:00', 2),
    ('Penеlope_Cruz', '2022-06-22', '10:00:00', 1),
    ('George_Clooney', '2022-06-22', '11:00:00', 1),
    ('George_Clooney', '2022-06-22', '21:00:00', 2),
    ('Penеlope_Cruz', '2022-06-22', '23:00:00', 2);
-- SELECT * FROM time_tracking;
-- DROP TABLE IF EXISTS friends;
CREATE TABLE IF NOT EXISTS friends (
    id serial NOT NULL PRIMARY KEY,
    peer_1 varchar(50),
    peer_2 varchar(50),
    CONSTRAINT friends_peer_1_fkey FOREIGN KEY (peer_1) REFERENCES peers (nickname) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT friends_peer_2_fkey FOREIGN KEY (peer_2) REFERENCES peers (nickname) ON UPDATE NO ACTION ON DELETE NO ACTION
);
ALTER TABLE IF EXISTS friends OWNER to postgres;
INSERT INTO friends (peer_1, peer_2)
VALUES ('Leonardo_DiCaprio', 'George_Clooney'),
    ('Leonardo_DiCaprio', 'Anthony_Hopkins'),
    ('George_Clooney', 'Anthony_Hopkins'),
    ('George_Clooney', 'Natalie_Portman'),
    ('Morgan_Freeman', 'Clint_Eastwood'),
    ('Kate_Winslet', 'Clint_Eastwood'),
    ('Martin_Scorsese', 'Kate_Winslet'),
    ('Clint_Eastwood', 'George_Clooney'),
    ('Anthony_Hopkins', 'Martin_Scorsese'),
    ('Anthony_Hopkins', 'Natalie_Portman');
-- SELECT *
-- FROM friends;
--TRUNCATE peers CASCADE;
--TRUNCATE tasks CASCADE;
--TRUNCATE checks CASCADE;
--TRUNCATE friends CASCADE;
--TRUNCATE p2p CASCADE;
--TRUNCATE recommendations CASCADE;
--TRUNCATE time_tracking CASCADE;
--TRUNCATE transferred_points CASCADE;
--TRUNCATE verter CASCADE;
--TRUNCATE xp CASCADE;
-- DROP PROCEDURE import_from_csv();
CREATE OR REPLACE PROCEDURE import_from_csv (
        IN tablename varchar(20),
        IN file_path text,
        IN delim char(1)
    ) AS $$ BEGIN EXECUTE format(
        'COPY %s FROM %L WITH DELIMITER %L CSV HEADER;',
        tablename,
        file_path,
        delim
    );
END;
$$ LANGUAGE plpgsql;
--CALL import_from_csv('peers', '/home/morfinpo/sql/SQL2_Info21_v1.0-0/src/csv_import/peers.csv', ',');
--CALL import_from_csv('tasks', '/home/morfinpo/sql/SQL2_Info21_v1.0-0/src/csv_import/tasks.csv', ',');  -- перепроверить
--CALL import_from_csv('checks', '/home/morfinpo/sql/SQL2_Info21_v1.0-0/src/csv_import/checks.csv', ',');
--CALL import_from_csv('p2p', '/home/morfinpo/sql/SQL2_Info21_v1.0-0/src/csv_import/p2p.csv', ',');      -- перепроверить
--CALL import_from_csv('friends', '/home/morfinpo/sql/SQL2_Info21_v1.0-0/src/csv_import/friends.csv', ',');
--CALL import_from_csv('xp', '/home/morfinpo/sql/SQL2_Info21_v1.0-0/src/csv_import/xp.csv', ',');
--CALL import_from_csv('recommendations', '/home/morfinpo/sql/SQL2_Info21_v1.0-0/src/csv_import/recommendations.csv', ',');
--CALL import_from_csv('verter', '/home/morfinpo/sql/SQL2_Info21_v1.0-0/src/csv_import/verter.csv', ',');
--CALL import_from_csv('transferred_points', '/home/morfinpo/sql/SQL2_Info21_v1.0-0/src/csv_import/transferred_points.csv', ',');
--CALL import_from_csv('time_tracking', '/home/morfinpo/sql/SQL2_Info21_v1.0-0/src/csv_import/time_tracking.csv', ',');
--DROP PROCEDURE export_to_csv();
CREATE OR REPLACE PROCEDURE export_to_csv (
        IN tablename varchar(20),
        IN file_path text,
        IN delim char(1)
    ) AS $$ BEGIN EXECUTE format(
        'COPY %s TO %L WITH CSV DELIMITER %L HEADER;',
        tablename,
        file_path,
        delim
    );
END;
$$ LANGUAGE plpgsql;
--CALL export_to_csv('checks', '/home/morfinpo/sql/SQL2_Info21_v1.0-0/src/csv_export/checks.csv', ',');
--CALL export_to_csv('friends', '/home/morfinpo/sql/SQL2_Info21_v1.0-0/src/csv_export/friends.csv', ',');
--CALL export_to_csv('p2p', '/home/morfinpo/sql/SQL2_Info21_v1.0-0/src/csv_export/p2p.csv', ',');
--CALL export_to_csv('peers', '/home/morfinpo/sql/SQL2_Info21_v1.0-0/src/csv_export/checks.csv', ',');
--CALL export_to_csv('recommendations', '/home/morfinpo/sql/SQL2_Info21_v1.0-0/src/csv_export/checks.csv', ',');
--CALL export_to_csv('tasks', '/homse/morfinpo/sql/SQL2_Info21_v1.0-0/src/csv_export/tasks.csv', ',');
--CALL export_to_csv('time_tracking', '/home/morfinpo/sql/SQL2_Info21_v1.0-0/src/csv_export/time_tracking.csv', ',');
--CALL export_to_csv('transferred_points', '/home/morfinpo/sql/SQL2_Info21_v1.0-0/src/csv_export/transferred_points.csv', ',');
--CALL export_to_csv('verter', '/home/morfinpo/sql/SQL2_Info21_v1.0-0/src/csv_export/verter.csv', ',');
--CALL export_to_csv('xp', '/home/morfinpo/sql/SQL2_Info21_v1.0-0/src/csv_export/xp.csv', ',');


-- Очистка базы
/*-------------------------------------------------------------------------------------------------------------------*/

-- TRUNCATE checks, friends, p2p, peers, recommendations, tasks, time_tracking, transferredpoints, verter, xp CASCADE;
-- DROP TYPE IF EXISTS checkstatus CASCADE;

/*-------------------------------------------------------------------------------------------------------------------*/
-- Дополнения данных для проверки запросов.



INSERT INTO time_tracking(peer, date, time, "state")
VALUES ('Clint_Eastwood', '2022-05-02', '08:00:00', 1),
       ('Clint_Eastwood', '2022-06-02', '18:00:00', 2),
	   ('Natalie_Portman', '2022-05-02', '23:00:00', 1),
       ('Natalie_Portman', '2022-06-02', '01:00:00', 2),
	   ('Sandra_Bullock', '2022-06-02', '18:00:00', 1);



INSERT INTO Checks (peer, task, date)
VALUES ('Sandra_Bullock', 'C8_3DViewer_v1.0', '2023-01-31');

INSERT INTO P2P ("check", checking_peer, "state", time)
VALUES (18, 'Sandra_Bullock', 'Start', '09:00:00'),
       (18, 'Sandra_Bullock', 'Success', '09:22:00');

INSERT INTO XP ("check", xp_amount)
VALUES (18, 750);


INSERT INTO time_tracking(peer, date, time, "state")
VALUES ('Leonardo_DiCaprio', DATE(timeofday()), '08:00:00', 1),
       ('Leonardo_DiCaprio', DATE(timeofday()), '18:00:00', 2),
       ('George_Clooney', DATE(timeofday()), '18:30:00', 1),
       ('George_Clooney', DATE(timeofday()), '23:30:00', 2);


INSERT INTO Transferred_Points(checking_peer, checked_peer, points_amount)
VALUES('George_Clooney',	'Sandra_Bullock', 1),
        ('Natalie_Portman', 'George_Clooney', 2),
        ('Sandra_Bullock', 'Natalie_Portman', 3),
        ('Clint_Eastwood', 'Sandra_Bullock', 5),
		('Sandra_Bullock', 'Clint_Eastwood', 4);


INSERT INTO Checks (peer, task, date)
VALUES ('Penеlope_Cruz', 'DO1_Linux', '2022-08-19'),
        ('Penеlope_Cruz', 'DO2_Linux Network', '2022-08-20'),
		('Penеlope_Cruz', 'DO3_LinuxMonitoring v1.0', '2022-08-21'),
		('Penеlope_Cruz', 'DO4_LinuxMonitoring v2.0', '2022-08-22'),
		('Penеlope_Cruz', 'DO5_SimpleDocker', '2022-08-23'),
		('Penеlope_Cruz', 'DO6_CICD', '2022-08-24');

INSERT INTO P2P ("check", checking_peer, "state", time)
VALUES (19, 'Penеlope_Cruz', 'Start', '09:00:00'),
       (19, 'Penеlope_Cruz', 'Success', '09:30:00'),
	   (20, 'Penеlope_Cruz', 'Start', '09:00:00'),
       (20, 'Penеlope_Cruz', 'Success', '09:30:00'),
	   (21, 'Penеlope_Cruz', 'Start', '09:00:00'),
       (21, 'Penеlope_Cruz', 'Success', '09:30:00'),
	   (22, 'Penеlope_Cruz', 'Start', '09:00:00'),
       (22, 'Penеlope_Cruz', 'Success', '09:30:00'),
	   (23, 'Penеlope_Cruz', 'Start', '09:00:00'),
       (23, 'Penеlope_Cruz', 'Success', '09:30:00'),
       (24, 'Penеlope_Cruz', 'Start', '09:00:00'),
       (24, 'Penеlope_Cruz', 'Success', '09:30:00');

INSERT INTO XP ("check", xp_amount)
VALUES (19, 300),
       (20, 250),
       (21, 350),
       (22, 350),
       (23, 300),
       (24, 300);

     
INSERT INTO Checks (peer, task, date)
VALUES
	 ('Penеlope_Cruz', 'C4_s21_math', '2022-01-06'),
   ('Natalie_Portman', 'C2_SimpleBashUtils', '2022-01-10'),
   ('Leonardo_DiCaprio', 'C5_s21_decimal', '2022-01-01'),
('Sandra_Bullock', 'DO1_Linux', '2022-01-03'),
('Clint_Eastwood', 'DO1_Linux', '2022-01-07');

INSERT INTO P2P ("check", checking_peer, state, time)
VALUES
	(25, 'Penеlope_Cruz', 'Start', '22:00:00'), 
    (25, 'Penеlope_Cruz', 'Success', '23:00:00'),
    (26, 'Natalie_Portman', 'Start', '22:00:00'),
    (26, 'Natalie_Portman', 'Success', '23:00:00'),
    (27, 'Leonardo_DiCaprio', 'Start', '22:00:00'),
    (27, 'Leonardo_DiCaprio', 'Success', '23:00:00'),
    (28, 'Sandra_Bullock', 'Start', '04:00:00'),
    (28, 'Sandra_Bullock', 'Success', '05:00:00'),
    (29, 'Clint_Eastwood', 'Start', '05:00:00'),
    (29, 'Clint_Eastwood', 'Failure', '06:00:00');

INSERT INTO Verter("check", "state", Time)
VALUES
	(25, 'Start', '07:01'),   
    (25, 'Success', '07:02'),
	(26, 'Start', '08:01'),
    (26, 'Success', '08:02'),
	(27, 'Start', '09:01'),
    (27, 'Success', '09:02'),
	(28, 'Start', '10:01'),
    (28, 'Success', '10:02'),
	(29, 'Start', '11:01'),
    (29, 'Failure', '11:02');


INSERT INTO XP ("check", xp_amount)
VALUES 
(25, 300),
	
	(26, 300),
	
	(27, 300),
	
	(28, 300);



INSERT INTO time_tracking(peer, date, time, "state")
VALUES ('Leonardo_DiCaprio', DATE(NOW()), '08:00:00', 1),
       ('Leonardo_DiCaprio',DATE(NOW()), '10:00:00', 2),
	   ('George_Clooney', DATE(NOW()), '18:30:00', 1),
       ('George_Clooney', DATE(NOW()), '23:30:00', 2),
	   ('Martin_Scorsese', DATE(NOW()), '16:37:01', 1),
       ('Martin_Scorsese', DATE(NOW()), '23:31:05', 2),
	   ('Anthony_Hopkins', DATE(NOW()), '16:37:00', 1),
       ('Anthony_Hopkins', DATE(NOW()), '23:31:05', 2);



INSERT INTO Recommendations (peer, recommendet_peer)
VALUES ('Sandra_Bullock', 'George_Clooney'),
       ('Sandra_Bullock', 'Morgan_Freeman'),
       ('Natalie_Portman', 'Sandra_Bullock'),
       ('Natalie_Portman', 'Leonardo_DiCaprio'),
       ('Natalie_Portman', 'Penеlope_Cruz'),
       ('Morgan_Freeman', 'Clint_Eastwood'),
       ('Morgan_Freeman', 'Kate_Winslet'),
       ('Sandra_Bullock', 'George_Clooney'),
       ('Sandra_Bullock', 'Martin_Scorsese'),
       ('Sandra_Bullock', 'Natalie_Portman'),
       ('Penеlope_Cruz', 'Martin_Scorsese'),
	   ('George_Clooney', 'Morgan_Freeman');



INSERT INTO time_tracking(peer, date, time, "state")
VALUES ('Leonardo_DiCaprio', DATE(current_date - 1), '08:00:00', 1),
       ('Leonardo_DiCaprio',DATE(current_date - 1), '10:00:00', 2),
	   ('Leonardo_DiCaprio', DATE(current_date - 1), '11:00:00', 1),
       ('Leonardo_DiCaprio',DATE(current_date - 1), '12:00:00', 2),
	   ('Leonardo_DiCaprio', DATE(current_date - 1), '12:01:00', 1),
       ('Leonardo_DiCaprio',DATE(current_date - 1), '20:00:00', 2),
	   ('George_Clooney', DATE(current_date - 1), '08:00:00', 1),
       ('George_Clooney',DATE(current_date - 1), '10:00:00', 2),
	   ('George_Clooney', DATE(current_date - 1), '11:00:00', 1),
       ('George_Clooney',DATE(current_date - 1), '12:00:00', 2),
	   ('George_Clooney', DATE(current_date - 1), '12:02:00', 1),
       ('George_Clooney',DATE(current_date - 1), '20:00:00', 2);



INSERT INTO peers (nickname, birthday)
VALUES ('Cheburashka', '1996-02-02'),
		('Shapoklyak', '1996-02-12');

INSERT INTO time_tracking(peer, date, time, "state")
VALUES ('Cheburashka', '2022-05-02', '08:00:00', 1),
       ('Cheburashka', '2022-05-02', '18:00:00', 2),
       ('Cheburashka', '2022-07-02', '18:30:00', 1),
       ('Cheburashka', '2022-07-02', '23:30:00', 2),
       ('Cheburashka', '2022-08-02', '18:10:00', 1),
       ('Cheburashka', '2022-08-02', '21:00:00', 2),
       ('Shapoklyak', '2022-06-22', '11:00:00', 1),
       ('Shapoklyak', '2022-06-22', '21:00:00', 2),
       ('Shapoklyak', '2022-06-22', '14:00:00', 1),
       ('Shapoklyak', '2022-06-22', '23:00:00', 2);
			

