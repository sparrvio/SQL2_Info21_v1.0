--select * from peers;
--select * from tasks;
--select * from checks;
--select * from friends;
--select * from p2p;
--select * from recommendations;
--select * from time_tracking;
--select * from transferred_points;
--select * from verter;
--select * from xp;
/*1) Написать процедуру добавления проверки P2P
 Параметры: ник проверяемого, ник проверяющего, название задачи, статус P2P проверки , время. 
 Если статус «старт», добавьте запись в таблицу «Проверки» (используйте сегодняшнюю дату). 
 Добавьте запись в таблицу P2P. 
 Если статус «старт», в качестве проверки укажите только что добавленную запись, в противном случае укажите проверку с незавершенным шагом P2P.*/
--DROP PROCEDURE IF EXISTS add_check_p2p();
CREATE OR REPLACE PROCEDURE add_check_p2p(
        IN checking_p VARCHAR(50),
        IN checked_p VARCHAR(50),
        IN title TEXT,
        IN p2p_state checkstatus,
        IN p2p_time TIME
    ) AS $$
DECLARE check_id INT DEFAULT 0;
BEGIN IF p2p_state = 'Start' THEN check_id = (
    SELECT MAX(id) + 1
    FROM checks
);
INSERT INTO checks(id, peer, task, date)
VALUES(check_id, checked_p, title, NOW());
ELSE check_id = (
    SELECT checks.id
    FROM p2p
        JOIN checks ON p2p."check" = checks.id
    WHERE p2p.checking_peer = checking_p
        AND task = title
        AND checks.peer = checked_p
);
END IF;
INSERT INTO p2p (id, "check", checking_peer, "state", time)
VALUES (
        (
            SELECT MAX(id) + 1
            FROM p2p
        ),
        check_id,
        checking_p,
        p2p_state,
        p2p_time
    );
END;
$$ LANGUAGE plpgsql;
--должны добавиться
--CALL add_check_p2p('Kate_Winslet','Morgan_Freeman','C4_s21_math','Start','10:23');
--CALL add_check_p2p('Kate_Winslet','Morgan_Freeman','C4_s21_math','Success','10:55');
--CALL add_check_p2p('Kate_Winslet','Natalie_Portman','C4_s21_math','Start','11:23');
--CALL add_check_p2p('Kate_Winslet','Natalie_Portman','C4_s21_math','Failure','11:55');
--не должны добавиться
--CALL add_check_p2p('Kate_Winslet','Natalie_Portman','C4_s21_math','Failure','11:55');
--DELETE FROM p2p CASCADE WHERE id IN (34,35,36,37);
--DELETE FROM checks CASCADE WHERE id IN (18,19);
/*2) Написать процедуру добавления проверки Verter'ом
 Параметры: ник проверяемого, название задания, статус проверки Verter'ом, время. 
 Добавить запись в таблицу Verter (в качестве проверки указать проверку соответствующего задания с самым поздним (по времени) успешным P2P этапом)*/
--DROP PROCEDURE IF EXISTS add_check_verter();
CREATE OR REPLACE PROCEDURE add_check_verter (
        IN checking_p VARCHAR(50),
        IN title TEXT,
        IN verter_state checkstatus,
        IN verter_time TIME
    ) AS $$
DECLARE check_id INT = (
        SELECT checks.id
        FROM p2p
            JOIN checks ON p2p.check = checks.id
        WHERE p2p."state" = 'Success'
            AND checks.peer = checking_p
            AND checks.task = title
        ORDER BY time DESC,
            time DESC
        LIMIT 1
    );
BEGIN
INSERT INTO verter (id, "check", "state", "time")
VALUES (
        (
            SELECT MAX(id) + 1
            FROM verter
        ),
        check_id,
        verter_state,
        verter_time
    );
END;
$$ LANGUAGE plpgsql;
--должны добавиться
--CALL add_check_verter('Morgan_Freeman','C4_s21_math','Start','11:00');
--CALL add_check_verter('Morgan_Freeman','C4_s21_math','Failure','11:01');
--CALL add_check_verter('Morgan_Freeman','C4_s21_math','Start','11:15');
--CALL add_check_verter('Morgan_Freeman','C4_s21_math','Success','11:25');
-- не должна добавиться
--CALL add_check_verter('Clint_Eastwood','D01_Linux','Start','11:15');
--DELETE FROM verter WHERE id IN (15,16,17,18);
--DELETE FROM verter WHERE id = 16;
--3) Написать триггер: после добавления записи со статутом "начало" в таблицу P2P, изменить соответствующую запись в таблице TransferredPoints
--DROP PROCEDURE IF EXISTS fnc_add_points_after_p2p();
CREATE OR REPLACE FUNCTION fnc_add_points_after_p2p() RETURNS TRIGGER AS $$
DECLARE name_peer VARCHAR(50);
BEGIN name_peer = (
    SELECT peer
    FROM checks
    WHERE id = NEW.check
);
UPDATE transferred_points
SET points_amount = points_amount + 1
WHERE checking_peer = NEW.checking_peer
    AND checked_peer = name_peer;
IF NOT FOUND THEN
INSERT INTO transferred_points (checking_peer, checked_peer, points_amount)
VALUES (NEW.checking_peer, name_peer, 1);
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trg_add_points_after_p2p
AFTER
INSERT ON P2P FOR EACH ROW
    WHEN(NEW.state = 'Start') EXECUTE FUNCTION fnc_add_points_after_p2p();
--CALL add_check_p2p('Kate_Winslet','Morgan_Freeman','C4_s21_math','Start','10:23');
--CALL add_check_p2p('Leonardo_DiCaprio','Kate_Winslet','C4_s21_math','Start','23:23');
--DELETE FROM transferred_points WHERE id = 5;
/*4) Написать триггер: перед добавлением записи в таблицу XP, проверить корректность добавляемой записи
 Запись считается корректной, если:
 
 Количество XP не превышает максимальное доступное для проверяемой задачи
 Поле Check ссылается на успешную проверку
 Если запись не прошла проверку, не добавлять её в таблицу.*/
/*delete from p2p where id IN (34,35)
 delete from p2p where id = 35
 delete from verter where id = 15
 delete from checks where id = 18
 delete from xp where id = 10
 delete from transferred_points where id = 16*/
CREATE OR REPLACE FUNCTION fnc_xp_insert() RETURNS trigger AS $$
DECLARE check_status VARCHAR(50);
max_xp INT;
BEGIN
SELECT tasks.max_xp INTO max_xp
FROM checks
    JOIN tasks ON tasks.title = checks.task
WHERE NEW."check" = checks.id;
IF NEW.xp_amount > max_xp THEN RAISE EXCEPTION 'Количество XP превышает максимальное значение для данной задачи';
END IF;
SELECT p2p.state INTO check_status
FROM p2p
    JOIN checks ON p2p."check" = checks.id
WHERE NEW."check" = checks.id
ORDER BY "state" DESC
LIMIT 1;
IF check_status <> 'Success' THEN RAISE EXCEPTION 'Ссылка на успешную проверку не найдена';
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trg_xp_insert BEFORE
INSERT ON xp FOR EACH ROW EXECUTE FUNCTION fnc_xp_insert();
--добавление записи к успешной проверке, но если xp указано больше возможного
--INSERT INTO xp VALUES (21, 3, 350); 
--добавление записи к успешной проверке p2p
--INSERT INTO xp VALUES (21, 3, 300); 
--попытка добавления записи к проваленной p2p проверке
--INSERT INTO xp VALUES (22, 31, 300);
