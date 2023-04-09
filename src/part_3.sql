DROP FUNCTION IF EXISTS s21_01_return_table_transferredPoints();

CREATE OR REPLACE FUNCTION s21_01_return_table_transferredPoints ()
  RETURNS TABLE (Peer1 varchar, Peer2 varchar, Points_Amount smallint)
  AS $$
	SELECT one.checking_peer AS Peer1, one.checked_peer AS Peer2,  
		COALESCE (one.points_amount, 0) - COALESCE (two.points_amount, 0) AS Points_Amount 
		FROM Transferred_Points AS one FULL JOIN Transferred_Points AS two
		ON one.checking_peer = two.checked_peer AND one.checked_peer = two.checking_peer 
		WHERE one.checking_peer IS NOT NULL 
    ORDER BY 3
  $$ LANGUAGE SQL;
  
-- SELECT * FROM s21_01_return_table_transferredPoints();
/*-------------------------------------------------------------------------------------------------------------------*/

DROP FUNCTION IF EXISTS s21_02_return_table();

CREATE OR REPLACE FUNCTION s21_02_return_table()
  RETURNS TABLE (Peer varchar, Task varchar, XP smallint)
  AS $$
		SELECT peer, task, xp_amount AS xp 
		FROM checks JOIN XP
		ON checks.id = xp.check	
  $$ LANGUAGE SQL;
  
-- SELECT * FROM s21_02_return_table();

/*-------------------------------------------------------------------------------------------------------------------*/

DROP FUNCTION IF EXISTS s21_03_peer_not_exit_campus (IN date_check_exit date);

CREATE OR REPLACE FUNCTION s21_03_peer_not_exit_campus (IN date_check_exit date) RETURNS TABLE (Peer varchar(24)) 
AS $$
		SELECT peer FROM time_tracking 
		GROUP BY peer, date
		HAVING time_tracking.date = date_check_exit AND (SUM(state) = 1 OR SUM(state) = 2)
$$ LANGUAGE SQL;

-- SELECT * FROM s21_03_peer_not_exit_campus('05.02.2022');

/*-------------------------------------------------------------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS s21_04_peer_points_change(IN ref refcursor);

CREATE OR REPLACE PROCEDURE s21_04_peer_points_change(IN ref refcursor)
AS $$
BEGIN
	CREATE OR REPLACE VIEW get_points AS (
			WITH get_points AS ( 		-- сколько пир заработал пойнтов
				SELECT checking_peer, SUM(points_amount) FROM Transferred_Points
				GROUP BY checking_peer
			), return_points AS ( 		-- сколько пир потратил поитнов
				SELECT checked_peer, SUM(points_amount) FROM Transferred_Points
				GROUP BY checked_peer
			)
			SELECT get_points.checking_peer AS Peer, (get_points.sum - return_points.sum) AS Points_Change
			FROM get_points JOIN return_points
			ON checking_peer = checked_peer -- запрос формирует VIEW
			ORDER BY 2 DESC
	);	
	OPEN ref FOR
		SELECT * FROM get_points; -- выводим данные из VIEW через рефкурсор
	DROP VIEW get_points;
END;
$$ LANGUAGE plpgsql;
	
-- BEGIN;
-- CALL s21_04_peer_points_change('ref');
-- FETCH ALL IN "ref";
-- ROLLBACK;

/*-------------------------------------------------------------------------------------------------------------------*/

DROP PROCEDURE IF EXISTS s21_05_peer_points_change_in_func(IN ref refcursor);

CREATE OR REPLACE PROCEDURE s21_05_peer_points_change_in_func(IN ref refcursor)
AS $$
	BEGIN
	OPEN ref FOR
		WITH t1 AS (
			SELECT peer1 AS peer, SUM(points_amount) AS Points_Change FROM s21_01_return_Table_TransferredPoints ()
			WHERE points_amount > 0
			GROUP BY peer1
			), t2 AS (
			SELECT peer2 AS peer, SUM(points_amount) AS Points_Change FROM s21_01_return_Table_TransferredPoints ()
			WHERE points_amount > 0
			GROUP BY peer2
			)
		SELECT COALESCE (t1.peer, t2.peer) AS peer, 
		COALESCE (t1.points_change, 0) - COALESCE (t2.points_change, 0) AS Points_Change
		FROM t1 FULL JOIN t2 ON t1.peer = t2.peer;
	END;
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL s21_05_peer_points_change_in_func('ref');
-- FETCH ALL IN "ref";
-- ROLLBACK;
/*-------------------------------------------------------------------------------------------------------------------*/

DROP PROCEDURE IF EXISTS s21_06_top_rate_review(IN ref refcursor);
CREATE OR REPLACE PROCEDURE s21_06_top_rate_review(IN ref refcursor)
AS $$
BEGIN
	OPEN ref FOR
	WITH t1 AS (
		SELECT to_char(checks.date, 'dd.mm.yyyy') AS Day, split_part(checks.task, '_', 1) AS task, COUNT (*) AS cnt FROM p2p 
		LEFT JOIN checks ON p2p.check = checks.id
		GROUP BY checks.task, checks.date
		ORDER BY 1 DESC
		), t2 AS (SELECT day, task, MAX(cnt) OVER (PARTITION BY "day") AS cnt FROM t1)

		SELECT t1.day AS day, t1.task AS task 
		FROM t1 RIGHT JOIN t2 
		ON t1.day = t2.day AND t1.task = t2.task AND t1.cnt = t2.cnt 
		WHERE t1.day IS NOT NULL;
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL s21_06_top_rate_review('ref');
-- FETCH ALL IN "ref";
-- ROLLBACK;

/*-------------------------------------------------------------------------------------------------------------------*/

DROP PROCEDURE IF EXISTS  s21_07_peers_finish_block(IN task_in varchar(24), IN ref refcursor);

CREATE OR REPLACE PROCEDURE s21_07_peers_finish_block(IN task_in varchar(24), IN ref refcursor)
AS $$
	BEGIN		
		OPEN ref FOR
		WITH table_block AS ( 
			SELECT peer, checks.task, date, COUNT(checks.task) OVER (PARTITION BY peer) AS cnt 
			FROM p2p LEFT JOIN verter
			ON p2p.check = verter.check LEFT JOIN checks
			ON p2p.check = checks.id 
			WHERE p2p.state = 'Success' AND (verter.state = 'Success' OR verter.state IS NULL) 
			AND checks.task IN (
				SELECT title FROM tasks WHERE title SIMILAR TO CONCAT(task_in, '[0-9]%')
				)
			)			
			SELECT peer AS peer, to_char(MAX(date), 'dd.mm.yyyy') AS day
			FROM table_block
			WHERE cnt = (SELECT COUNT(title) FROM tasks WHERE title SIMILAR TO CONCAT(task_in, '[0-9]%'))
			GROUP BY peer;
	END;
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL s21_07_peers_finish_block('DO','ref');
-- FETCH ALL IN "ref";
-- ROLLBACK;

/*-------------------------------------------------------------------------------------------------------------------*/

DROP PROCEDURE IF EXISTS  s21_8_best_peer_for_review(IN ref refcursor);

CREATE OR REPLACE PROCEDURE s21_8_best_peer_for_review(IN ref refcursor)
AS $$
 	BEGIN
 	OPEN ref FOR
		WITH t1 AS (
			SELECT 
			nickname AS peer, CASE WHEN nickname = peer_1 THEN peer_2 ELSE peer_1 END AS friend
			FROM peers JOIN friends ON nickname = peer_1 OR nickname = peer_2
			ORDER BY 1
		), t2 AS (
			SELECT 
			t1.peer, recommendet_peer  FROM t1 LEFT JOIN recommendations 
			ON t1.friend = recommendations.peer
			WHERE recommendet_peer IS NOT NULL
			ORDER BY 1
		), t3 AS (
			SELECT peer, recommendet_peer, COUNT (recommendet_peer) AS cnt FROM t2
			GROUP BY peer, recommendet_peer
			ORDER BY 1
		), t4 AS (
			SELECT peer, recommendet_peer, cnt, MAX(cnt) OVER (PARTITION BY peer) AS max_cnt 
			FROM t3
			ORDER BY 1
		)
			SELECT peer, recommendet_peer AS RecommendedPeer FROM t4 
			WHERE max_cnt = cnt AND peer <> recommendet_peer;
 	END;
$$ LANGUAGE plpgsql;

--  BEGIN;
--  CALL s21_8_best_peer_for_review('ref');
--  FETCH ALL IN "ref";
--  ROLLBACK;

/*----------------------------------------------------------------------------------------------------------------
---*/
-- 11
DROP PROCEDURE IF EXISTS   s21_9_percent_peers_blocks(IN Block1 varchar, 
														IN Block2 varchar, 
														OUT StartedBlock1 real, 
														OUT StartedBlock2 real, 
														OUT StartedBothBlocks real, 
														OUT DidntStartAnyBlock real);	
CREATE OR REPLACE PROCEDURE s21_9_percent_peers_blocks(IN Block1 varchar, 
														IN Block2 varchar, 
														OUT StartedBlock1 real, 
														OUT StartedBlock2 real, 
														OUT StartedBothBlocks real, 
														OUT DidntStartAnyBlock real)										
AS $$
BEGIN
WITH BlockTable1 AS ( 
	-- мы должны послать в процедуру два параметра - часть начала названия двух проектов 
	-- эти два парамета передаются через переменные Block1 и Block2
	-- выбираем пира чье задание начинается на передаваемый Block1 плюс цифры используя конкатенацию
	--названия проектов состоят из буква+цифра и нижнее подчеркивание соответственно если пришла буква 'С' к примеру
	-- то процедура будет сравнивать фрагмент  С  +  цифра + _ и все что далее
	--
	SELECT DISTINCT peer FROM Checks 
	WHERE Checks.task SIMILAR TO concat(Block1, '[0-9]_%')),
	BlockTable2 AS (
	-- выбираем пира чье задание начинается на передаваемый Block2 плюс цифры
	SELECT DISTINCT peer FROM Checks 
	WHERE Checks.task SIMILAR TO concat(Block2, '[0-9]_%')),
	-- в третию  таблицу выбираем того кто попал и в  BlockTable1 и BlockTable2 
	BothBlock3 AS (
	SELECT DISTINCT BlockTable1.peer
    FROM BlockTable1
    INNER JOIN BlockTable2 ON BlockTable1.peer = BlockTable2.peer
	),
	NoBlock4 AS (
		-- четвертый столбец означает что никто ничего не начал делать 
		-- объединяем поисковый запрос для блока1 и блока 2 и исключаем повторяющиеся строки. Получаем 
		-- список всех кто начал то или иное задание чтобы затем длч столбца #4 вычесть это количество из общейго списка
		-- и получить тех кто вообще не начал ничего из запрашиваемого
	SELECT DISTINCT peer
    FROM ((SELECT * FROM BlockTable1) UNION (SELECT * FROM BlockTable2)) AS tmp)

	SELECT 	ROUND(CAST((SELECT COUNT(*) FROM BlockTable1) AS real) / (SELECT COUNT(*) FROM peers) * 100),
	 		ROUND(CAST((SELECT COUNT(*) FROM BlockTable2) AS real) / (SELECT COUNT(*) FROM peers) * 100),
	 		ROUND(CAST((SELECT COUNT(*) FROM BothBlock3) AS real) / (SELECT COUNT(*) FROM peers) * 100),
	 		ROUND(CAST((SELECT COUNT(*) FROM peers) - (SELECT COUNT(*) FROM NoBlock4) AS real) / (SELECT COUNT(*) FROM peers) * 100) 
	INTO StartedBlock1, StartedBlock2, StartedBothBlocks, DidntStartAnyBlock;
	
END;
	$$ LANGUAGE plpgsql;
CALL s21_9_percent_peers_blocks('C', 'DO', NULL, NULL, NULL, NULL);

 /*-------------------------------------------------------------------------------------------------------------------*/
 -- 10
DROP PROCEDURE IF EXISTS s21_10_percent_success_and_failure_checks_DR(OUT SuccessfulChecks real, OUT UnsuccessfulChecks real);
CREATE OR REPLACE PROCEDURE s21_10_percent_success_and_failure_checks_DR(OUT SuccessfulChecks real, OUT UnsuccessfulChecks real)
AS $$
BEGIN
WITH BirthDayCut AS (SELECT Nickname, EXTRACT(day FROM Birthday) AS BDDay, 
			 EXTRACT(month FROM Birthday) AS BDMonth FROM Peers),
-- 			 select * from P2P
	CheckDateCut AS (SELECT Checks.Id, Peer, EXTRACT(day FROM Date) AS ChkDay, 
			 EXTRACT(month FROM Date) AS ChkMonth, P2P.State 
			AS p2p, Verter.State AS VerterState FROM Checks
			JOIN P2P on Checks.Id = P2P.Check
			LEFT JOIN Verter ON Checks.Id = Verter.Check
			WHERE P2P.State IN ('Success', 'Failure') AND (Verter.State IN ('Success', 'Failure') 
			OR Verter.State IS NULL)),
	DateCompare AS (SELECT * FROM BirthDayCut
			  JOIN CheckDateCut ON BirthDayCut.BDDay = CheckDateCut.ChkDay AND BirthDayCut.BDMonth = CheckDateCut.ChkMonth),
	Result_OK AS (SELECT COUNT(*) AS success
			 FROM DateCompare  WHERE p2p = 'Success' AND (VerterState = 'Success' OR VerterState IS NULL)),
 	Result_Fail AS (SELECT COUNT(*) AS fail FROM DateCompare
 		WHERE p2p = 'Failure' OR VerterState = 'Failure')
   	 	SELECT ROUND((CAST((SELECT success FROM Result_OK) AS real  ) *100 / (SELECT COUNT(Nickname) FROM peers))),
   	   	ROUND((CAST((SELECT fail FROM Result_Fail) AS real ) * 100/ (SELECT COUNT(Nickname) FROM peers)))
  		INTO SuccessfulChecks,  UnsuccessfulChecks;
END;
$$ LANGUAGE plpgsql;

-- CALL s21_10_percent_success_and_failure_checks_DR(NULL, NULL);

 /*-------------------------------------------------------------------------------------------------------------------*/
 -- 11
 -- 11) Determine all peers who did the given tasks 1 and 2, but did not do task 3
-- Procedure parameters: names of tasks 1, 2 and 3. 
-- Output format: list of peers
-- select * from checks
-- select peer from Checks where Task = 'C2_SimpleBashUtils' 
-- from part 3 task 2:

DROP  PROCEDURE IF EXISTS s21_11_task1_task2_NO_task3 (IN Task1 varchar, 
 											IN Task2 varchar, 
 											IN Task3 varchar, 
 											IN ref_buf refcursor); 
CREATE OR REPLACE PROCEDURE s21_11_task1_task2_NO_task3 (IN Task1 varchar, 
											IN Task2 varchar, 
											IN Task3 varchar, 
											IN ref_buf refcursor)	
AS $$
	BEGIN
		OPEN ref_buf FOR --открыт буфер куда пишем результат поиска 
	WITH Peer_Task1 AS (
	SELECT  peer AS list_of_peers FROM  (SELECT peer, task, xp_amount AS xp 
  	FROM checks JOIN XP ON checks.id = xp.check) AS Result_Table
	WHERE Result_Table.Task = Task1
  	GROUP BY peer
	),
	Peer_Task2 AS (
	SELECT  peer AS list_of_peers FROM (SELECT peer, task, xp_amount AS xp 
  	FROM checks JOIN XP ON checks.id = xp.check)  AS Result_Table
	WHERE Result_Table.Task = Task2
  	GROUP BY peer
	),
	Peer_Task3 AS (
	SELECT  peer AS list_of_peers FROM (SELECT peer, task, xp_amount AS xp 
  	FROM checks JOIN XP ON checks.id = xp.check) AS Result_Table
	WHERE Result_Table.Task != Task3
  	GROUP BY peer
	)
	SELECT *
FROM ((SELECT * FROM Peer_Task1) INTERSECT (SELECT * FROM Peer_Task2) INTERSECT (SELECT * FROM Peer_Task3)) AS outcome 
ORDER BY list_of_peers;
END;
$$ LANGUAGE plpgsql;
-- BEGIN; 
-- CALL s21_11_task1_task2_NO_task3('DO2_Linux Network', 'C2_SimpleBashUtils', 'CPP6_3DViewer_v2.2','table1');
-- FETCH ALL IN "table1";
-- ROLLBACK;

 /*-------------------------------------------------------------------------------------------------------------------*/

DROP PROCEDURE IF EXISTS s21_12_recursive_task CASCADE;

CREATE OR REPLACE PROCEDURE s21_12_recursive_task(IN ref refcursor) 
AS $$
BEGIN
	OPEN ref FOR
	WITH RECURSIVE recur AS (
		SELECT title AS task, parent_task, 
		(CASE WHEN parent_task IS NOT NULL 
		THEN 1 ELSE 0 END) AS cnt                   		
    	FROM tasks
    UNION ALL
        SELECT c.title AS task, prev.task AS parrent_task, 
		(CASE WHEN c.parent_task IS NOT NULL 
		 THEN cnt + 1 ELSE cnt END) AS cnt                        
        FROM tasks AS c
        CROSS JOIN recur AS prev
        WHERE prev.task = c.parent_task)
        
		SELECT task, MAX(cnt) AS PrevCount FROM recur
        GROUP BY task;
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL s21_12_recursive_task('ref');
-- FETCH ALL IN "ref";
-- ROLLBACK;

/*-------------------------------------------------------------------------------------------------------------------*/
-- 13
-- CREATE OR REPLACE PROCEDURE s21_13_lucky_days(IN N integer, IN ref_buf refcursor)	
-- AS $$
-- BEGIN
-- OPEN ref_buf FOR --открыт буфер куда пишем результат поиска 
-- -- выбирать нужно не успешные сдачи  а все, со всеми статусами (успех\неуспех)
-- -- а потом проверять сверху вниз, что-то вроде счетчика - если успешная сдача, то плюс один, если неуспех - то сброс
DROP PROCEDURE IF EXISTS s21_13_lucky_day (IN Number_of_Checks integer, IN ref_buf refcursor);
CREATE OR REPLACE PROCEDURE s21_13_lucky_day (IN Number_of_Checks integer, IN ref_buf refcursor) 
AS $$ BEGIN OPEN ref_buf FOR 
WITH required_frame AS(
	-- https://oracleplsql.ru/function-sql-server-lead.html
-- 	https://www.youtube.com/watch?v=9nN_g4eIEgo
	--  запрос №1 - выделить дату время, и создать столбец  "следующий статус"
	-- который будет отразит содержание следующего значения в колонке статус. 
	-- Цифра 1 в вызове функции LEAD(status, 1)  - количество мест на которые происходит сдвиг поиска
	SELECT date, time, status, LEAD(status, 1) OVER (ORDER BY date, time) AS next_status
	-- из запроса №2: о данных из объединения таблиц checks, XP, P2P, Tasks: день, когда были успешные прооверки 
	-- и соблюдено условие начисления ХР не менее 80% от максимального из таблицы Tasks
	--  создаем столбец  "status" в который  поместим 1 или 0  
        FROM ( SELECT checks.date,
                 case WHEN 100 * xp.XP_Amount / tasks.Max_XP >= 80 THEN 1
                      ELSE 0
                END AS status, p2p.time
                FROM checks JOIN tasks ON checks.task = tasks.title
                    		JOIN xp ON checks.id = xp.check
                    		JOIN p2p ON checks.id = p2p.check
                    		AND p2p.state in('Success', 'Failure')) foo_1), 
preceeding_frame AS ( 
	-- объединяем таблицу (выше) саму с собой и выбираем совпадение дня проверки "RF_1.date = RF_2.date"
	--  с тем, чтобы время в рамках этого дня 
         SELECT RF_1.date, RF_1.time, RF_1.status, RF_1.next_status, COUNT (RF_2.date)
         FROM required_frame RF_1
         JOIN required_frame RF_2 on RF_1.date = RF_2.date AND RF_1.time <= RF_2.time AND RF_1.status = RF_2.next_status
         GROUP BY RF_1.date, RF_1.time, RF_1.status, RF_1.next_status)
SELECT date
FROM ( SELECT date, MAX(successful_checks) AS max_successful_checks
      FROM ( SELECT date, COUNT AS successful_checks FROM preceeding_frame WHERE status = 1) 
	  successful_checks GROUP BY date) foo_2 WHERE max_successful_checks >= Number_of_Checks;
END;
$$ LANGUAGE plpgsql;
-- BEGIN;
-- CALL s21_13_lucky_day (2, 'table1');
-- FETCH ALL FROM "table1";
-- ROLLBACK; 
/*-------------------------------------------------------------------------------------------------------------------*/
DROP PROCEDURE IF EXISTS  s21_14_peer_max_xp(OUT peer varchar(24), OUT xp integer);

CREATE OR REPLACE PROCEDURE s21_14_peer_max_xp(OUT peer varchar(24), OUT xp integer)
AS $$
BEGIN
	WITH table_xp AS (
	SELECT checks.peer, COUNT(checks.peer) as cnt, SUM(xp_amount) AS xp 
		FROM p2p LEFT JOIN verter
		ON p2p.check = verter.check LEFT JOIN checks
		ON p2p.check = checks.id LEFT JOIN xp
		ON checks.id = xp.check
		WHERE p2p.state = 'Success' AND (verter.state = 'Success' OR verter.state IS NULL) 
	GROUP BY checks.peer
	ORDER BY xp DESC
	)

	SELECT table_xp.peer, table_xp.xp FROM table_xp
	WHERE table_xp.xp IS NOT NULL
	INTO peer, xp;	
END;
$$ LANGUAGE plpgsql;

-- CALL s21_14_peer_max_xp(NULL, NULL);

/*-------------------------------------------------------------------------------------------------------------------*/

DROP PROCEDURE IF EXISTS  s21_15_before_time(IN time_in interval, IN number_enter integer, IN ref refcursor);

CREATE OR REPLACE PROCEDURE s21_15_before_time(IN time_in interval, IN number_enter integer, IN ref refcursor)
AS $$
BEGIN
OPEN ref FOR
	WITH time_enter AS (
	SELECT peer, date, MIN(time)FROM time_tracking
	WHERE state = 1
	GROUP BY date, peer
	), count_enter AS (
	SELECT peer, COUNT (peer) AS cnt FROM time_enter 
	WHERE min < time_in
	GROUP BY peer
	)
	SELECT peer FROM count_enter
	WHERE cnt >= number_enter;
    
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL s21_15_before_time('10:10:00', 1, 'ref');
-- FETCH ALL IN "ref";
-- ROLLBACK;

/*-------------------------------------------------------------------------------------------------------------------*/

DROP PROCEDURE IF EXISTS  s21_16_count_peer_out_campus(IN amount_day int, IN count_enter integer, IN ref refcursor);

CREATE OR REPLACE PROCEDURE s21_16_count_peer_out_campus(IN amount_day int, IN count_enter integer, IN ref refcursor)
AS $$
BEGIN
	OPEN ref FOR
	WITH t1 AS (
			SELECT * FROM time_tracking
			WHERE state = 2
		), t2 AS (
			SELECT peer, date, COUNT(state) - 1 AS cnt FROM t1
 			WHERE t1.date >=  current_date - amount_day
			GROUP BY peer, date
		) 
		SELECT peer FROM t2
 		WHERE cnt > count_enter;
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL s21_16_count_peer_out_campus(10, 0, 'ref');
-- FETCH ALL IN "ref";
-- ROLLBACK;
/*-------------------------------------------------------------------------------------------------------------------*/

DROP PROCEDURE IF EXISTS s21_17_percent_early_entries(IN ref refcursor);

CREATE OR REPLACE PROCEDURE s21_17_percent_early_entries(IN ref refcursor)
AS $$
BEGIN
	OPEN ref FOR
	WITH t1 AS (	
		SELECT *, to_char(peers.birthday, 'TMMonth') AS "Month"
		FROM Time_Tracking JOIN peers
		ON nickname = peer
		WHERE state = 1
		), t2 AS (
		SELECT peer, date, "Month", MIN(time) FROM t1
		GROUP BY peer, date, "Month"
		), t3 AS (	
		SELECT "Month", COUNT("Month") AS cnt FROM t2
		GROUP BY "Month"
		), t4 AS (	
		SELECT "Month", COUNT("Month") AS cnt  FROM t2 
		WHERE "min" < '12:00:00'
		GROUP BY "Month"
		)
		SELECT t4."Month", ROUND(CAST(t4.cnt AS real) / CAST(t3.cnt AS real) * 100)
		FROM t3 JOIN t4 ON t3."Month" = t4."Month";
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL s21_17_percent_early_entries('ref');
-- FETCH ALL IN "ref";
-- ROLLBACK;
