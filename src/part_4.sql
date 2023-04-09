-- create db
CREATE DATABASE s21_for_part_04
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

/*--------------------------------------------------------*/-- for part_04_01
CREATE TABLE IF NOT EXISTS TableName (a numeric);
CREATE TABLE IF NOT EXISTS TableName12 (a varchar);
CREATE TABLE IF NOT EXISTS TableName123 (a text);
CREATE TABLE IF NOT EXISTS TableNameTable (a bigint);
CREATE TABLE IF NOT EXISTS TableNameName (a date);
CREATE TABLE IF NOT EXISTS TableName_Drop (a integer);

/*--------------------------------------------------------*/-- for part_04_02
CREATE OR REPLACE FUNCTION test() RETURNS real AS $$
BEGIN
    RETURN 0.06;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION test_1(subtotal integer) RETURNS real AS $$
BEGIN
    RETURN subtotal * 0.06;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION test_2(IN ptest varchar default 'test') RETURNS real AS $$
BEGIN
    RETURN ptest;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION test_3 (VARIADIC arr numeric[])
RETURNS numeric AS $$
    SELECT min($1[i]) FROM generate_subscripts($1, 1) g(i);
$$ LANGUAGE SQL;

/*--------------------------------------------------------*/-- for part_04_03

CREATE TABLE IF NOT EXISTS person
( id bigint primary key ,
  name varchar not null,
  age integer not null default 10,
  gender varchar default 'female' not null ,
  address varchar
);
  
CREATE OR REPLACE FUNCTION fnc_trg_person_insert_audit () RETURNS trigger AS $insert_audit$
	BEGIN
		IF(TG_OP = 'INSERT') THEN
		INSERT INTO person_audit SELECT NOW(), 'I', NEW.*;
	END IF;
	RETURN NULL;
	END;
$insert_audit$ 
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_person_insert_audit
AFTER INSERT ON person
FOR EACH ROW 
EXECUTE FUNCTION fnc_trg_person_insert_audit();

CREATE OR REPLACE FUNCTION fnc_trg_person_update_audit () RETURNS trigger AS $update_audit$
	BEGIN
		IF(TG_OP = 'UPDATE') THEN
		INSERT INTO person_audit SELECT NOW(), 'U', OLD.*;
	END IF;
	RETURN NULL;
	END;
$update_audit$ 
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_person_update_audit
AFTER UPDATE ON person
FOR EACH ROW 
EXECUTE FUNCTION fnc_trg_person_update_audit();

CREATE OR REPLACE FUNCTION fnc_trg_person_delete_audit () RETURNS trigger AS $delete_audit$
	BEGIN
		IF(TG_OP = 'DELETE') THEN
		INSERT INTO person_audit SELECT NOW(), 'D', OLD.*;
	END IF;
	RETURN NULL;
	END;
$delete_audit$ 
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_person_delete_audit
AFTER DELETE ON person
FOR EACH ROW 
EXECUTE FUNCTION fnc_trg_person_delete_audit();

CREATE OR REPLACE FUNCTION fnc_trg_person_audit () RETURNS trigger AS 
$person_audit$
	BEGIN
		IF (TG_OP = 'INSERT') THEN
			INSERT INTO person_audit SELECT NOW(), 'I', NEW.*;
		ELSIF (TG_OP = 'UPDATE') THEN
			INSERT INTO person_audit SELECT NOW(), 'U', OLD.*;
		ELSIF (TG_OP = 'DELETE') THEN
			INSERT INTO person_audit SELECT NOW(), 'D', OLD.*;
		END IF;
		RETURN NULL;
	END;
$person_audit$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_person_audit
AFTER INSERT OR UPDATE OR DELETE ON person
FOR EACH ROW 
EXECUTE FUNCTION fnc_trg_person_audit();

CREATE OR REPLACE FUNCTION s21_out_name_trigger(rec text) RETURNS text AS $$
BEGIN
    RETURN rec;
END;
$$ LANGUAGE plpgsql;

/*--------------------------------------------------------*/-- for part_04_04

CREATE OR REPLACE FUNCTION s21_compare_text(string_for_searh varchar(255), search_text varchar (255)) RETURNS integer AS $$
   SELECT position(search_text IN string_for_searh);
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION LANGUAGE_SQL () RETURNS text AS $$
    SELECT 'LANGUAGE_SQL';
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION LANGUAGE_SQL_1 () RETURNS integer AS $$
    SELECT 1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION LANGUAGE_SQL_2 () RETURNS numeric AS $$
    SELECT 1.123;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION LANGUAGE_SQL_3 () RETURNS date AS $$
    SELECT now();
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION LANGUAGE_SQL_4 () RETURNS text AS $$
    SELECT age(timestamp '2001-04-10', timestamp '1957-06-13');
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION LANGUAGE_SQL_5 () RETURNS text AS $$
    SELECT make_time(8, 15, 23.5);
$$ LANGUAGE SQL;

CREATE OR REPLACE PROCEDURE LANGUAGE_SQL_6()
AS $$
	BEGIN;
	SELECT make_time(8, 15, 23.5);
	ROLLBACK;
$$ LANGUAGE SQL;

CREATE OR REPLACE PROCEDURE LANGUAGE_SQL_7()
AS $$
	BEGIN;
	SELECT 'LANGUAGE_SQL';
	ROLLBACK;
$$ LANGUAGE SQL;

CREATE OR REPLACE PROCEDURE LANGUAGE_SQL_8()
AS $$
	BEGIN;
	SELECT age(timestamp '2001-04-10', timestamp '1957-06-13');
	ROLLBACK;
$$ LANGUAGE SQL;

CREATE OR REPLACE PROCEDURE LANGUAGE_SQL_9()
AS $$
	BEGIN;
	SELECT now();
	ROLLBACK;
$$ LANGUAGE SQL;

CREATE OR REPLACE PROCEDURE LANGUAGE_SQL_10()
AS $$
	BEGIN;
	SELECT * FROM information_schema.routines AS rout
	WHERE routine_type IN ('FUNCTION', 'PROCEDURE') AND routine_body = 'SQL'
	AND routine_schema NOT IN ('information_schema', 'pg_catalog');
	ROLLBACK;
$$ LANGUAGE SQL;

/*--------------------------------------------------------*/
-- 1) Создать хранимую процедуру, которая, не уничтожая базу данных, 
-- уничтожает все те таблицы текущей базы данных, имена -- которых начинаются с фразы 'TableName'.

-- SELECT * FROM INFORMATION_SCHEMA.TABLES
-- WHERE table_schema NOT IN ('information_schema', 'pg_catalog');

CREATE OR REPLACE PROCEDURE del_tables_named_TableName()
AS $$
BEGIN
	EXECUTE 'DROP TABLE IF EXISTS ' || COALESCE((SELECT string_agg(table_name, ',')
	FROM INFORMATION_SCHEMA.TABLES
	WHERE table_name LIKE'tablename%' AND
	table_schema NOT IN ('information_schema', 'pg_catalog')), 'tablename') || ' CASCADE';
END;
	$$ LANGUAGE plpgsql;
	
-- CALL del_tables_named_TableName();

/*--------------------------------------------------------*/
-- 2) Создать хранимую процедуру с выходным параметром, которая выводит список имен и параметров 
-- всех скалярных SQL функций пользователя в текущей базе данных. Имена функций без параметров 
-- не выводить. Имена и список параметров должны выводиться в одну строку. 
-- Выходной параметр возвращает количество найденных функций.
/*--------------------------------------------------------*/
-- Наш вариант хранимой процедуры имеет ОДИН выходной параметр в котором возвращается количество функций.
-- Сам список функций с принимаемыми параметрами выводится во вкладке "Сообщения" (для PGAdin 4).
-- Реализация выполненна в соответствии с заданием.

-- Запрос выводит список функций в текущей БД
-- SELECT * FROM information_schema.routines AS rout
-- WHERE rout.routine_type = 'FUNCTION' AND
-- routine_schema NOT IN ('information_schema', 'pg_catalog');

-- Запрос выводит список функций с параметрами в текущей БД
-- SELECT * FROM information_schema.routines AS rout
-- 		JOIN information_schema.parameters AS par
-- 		ON rout.specific_name = par.specific_name
-- 		WHERE rout.routine_type = 'FUNCTION' AND
-- 		routine_schema NOT IN ('information_schema', 'pg_catalog')
-- 		AND par.parameter_name IS NOT NULL;

CREATE OR REPLACE PROCEDURE s21_show_scalar_func(OUT func_counter BIGINT) AS $$
DECLARE
	cur refcursor; -- объвляем рефкурсор
	rec text; -- объявляем переменную
BEGIN
	OPEN cur FOR -- открываем рефкурсор для результатов запроса
	SELECT routine_name ||' '|| parameter_name ||' '|| par.data_type
		FROM information_schema.routines AS rout
		JOIN information_schema.parameters AS par
		ON rout.specific_name = par.specific_name
		WHERE rout.routine_type = 'FUNCTION' AND
		routine_schema NOT IN ('information_schema', 'pg_catalog')
		AND par.parameter_name IS NOT NULL;
	LOOP
		FETCH cur INTO rec; -- кладем данные из рефкурсора в переменную...
		EXIT WHEN NOT FOUND; -- ... если строка не пустая
		RAISE NOTICE '%',  rec; -- выводим rec в сообщения
	END LOOP;
	CLOSE cur;

	SELECT COUNT(*) -- обычный count
	INTO func_counter -- выходной параметр для счетчика
	FROM (SELECT routine_name ||' '|| parameter_name ||' '|| par.data_type
		FROM information_schema.routines AS rout
		JOIN information_schema.parameters AS par
		ON rout.specific_name = par.specific_name
		WHERE rout.routine_type = 'FUNCTION' AND
		routine_schema NOT IN ('information_schema', 'pg_catalog')
		AND par.parameter_name IS NOT NULL) AS tmp;
END;
$$ LANGUAGE plpgsql;

-- CALL s21_show_scalar_func(0);

 /*--------------------------------------------------------------------------------*/ 
-- Вариант выполнения задания при котором функции выводся одной строкой

-- CREATE OR REPLACE PROCEDURE s21_show_scalar_func(OUT func_counter BIGINT)
-- AS $$
-- DECLARE
-- 	cur refcursor; -- объвляем рефкурсор
-- 	rec record; -- объявляем переменную типа record
-- BEGIN
--  		OPEN cur FOR -- открываем рефкурсор для результатов запроса
--             SELECT string_agg(routine_name ||' '||'('|| parameter_name ||' '|| par.data_type ||')', ', ') FROM information_schema.routines AS rout
--                 JOIN information_schema.parameters AS par
--                 ON rout.specific_name = par.specific_name
--                 WHERE rout.routine_type = 'FUNCTION' AND
--                 routine_schema NOT IN ('information_schema', 'pg_catalog')
--                 AND par.parameter_name IS NOT NULL;
-- 		LOOP
-- 			FETCH cur INTO rec; -- кладем данные из рефкурсора в переменную...
-- 			EXIT WHEN NOT FOUND; -- ... если строка не пустая
-- 			RAISE NOTICE '%',  rec; -- выводим rec в сообщения
-- 		END LOOP;
-- 		CLOSE cur;
 -- 		SELECT COUNT(*) -- обычный count
--         INTO func_counter -- выходной параметр для счетчика
--         FROM (SELECT routine_name FROM information_schema.routines AS rout -- это считаем
-- 		WHERE rout.routine_type = 'FUNCTION' AND
-- 		routine_schema NOT IN ('information_schema', 'pg_catalog')) AS tmp;
-- END;
-- $$ LANGUAGE plpgsql;
 -- CALL s21_show_scalar_func(0);


/*------------------------------------------------------------------------*/
-- 3) Создать хранимую процедуру с выходным параметром, которая уничтожает все SQL DML триггеры в текущей базе данных. 
-- Выходной параметр возвращает количество уничтоженных триггеров.

-- Триггер DML (INSERT — при создании строки, DELETE — при удалении строки и UPDATE — при изменении);
-- SELECT * FROM information_schema.triggers;

CREATE OR REPLACE PROCEDURE s21_del_triggers_DML(OUT trigger_counter BIGINT)
AS $$

DECLARE
	cur refcursor; -- объвляем рефкурсор
	rec text; -- объявляем переменную
BEGIN
	SELECT COUNT(*)	INTO trigger_counter
		FROM (SELECT trigger_name FROM information_schema.triggers
        WHERE event_manipulation IN ('INSERT', 'DELETE', 'UPDATE') AND  
        trigger_schema NOT IN ('information_schema', 'pg_catalog')) AS tmp;
			
	OPEN cur FOR
	SELECT trigger_name || ' on ' || event_object_table 
        FROM information_schema.triggers
        WHERE event_manipulation IN ('INSERT', 'DELETE', 'UPDATE') AND  
        trigger_schema NOT IN ('information_schema', 'pg_catalog');
LOOP
	FETCH cur INTO rec;
	EXIT WHEN NOT FOUND;
	EXECUTE 'DROP trigger IF EXISTS' ||' ' || (SELECT * from s21_out_name_trigger(rec));
END LOOP;
CLOSE cur;
END;
$$ LANGUAGE plpgsql;
	
-- CALL s21_del_triggers_DML(0);


/*------------------------------------------------------------------------*/
-- 4) Создать хранимую процедуру с входным параметром, которая выводит имена и описания типа объектов (только хранимых 
-- процедур и скалярных функций), в тексте которых на языке SQL встречается строка, задаваемая параметром процедуры.

CREATE OR REPLACE PROCEDURE s21_show_name_and_type(IN search_text text)
AS $$
DECLARE
	cur refcursor;
	string_for_searh varchar(255);
	count_str integer = 0;
BEGIN	
	OPEN cur FOR
		SELECT routine_definition FROM information_schema.routines AS rout
		WHERE routine_type IN ('FUNCTION', 'PROCEDURE') AND routine_body = 'SQL'
		AND routine_schema NOT IN ('information_schema', 'pg_catalog');
	LOOP 
		FETCH cur INTO string_for_searh;
		EXIT WHEN NOT FOUND;
		count_str = count_str + 1;
		IF (s21_compare_text(string_for_searh, search_text)) <> 0 THEN 
			RAISE NOTICE '%', (SELECT (CONCAT ('OBJECT NAME: ' || (SELECT routine_name FROM information_schema.routines AS rout
			WHERE routine_type IN ('FUNCTION', 'PROCEDURE') AND routine_body = 'SQL'
			AND routine_schema NOT IN ('information_schema', 'pg_catalog') LIMIT 1 OFFSET (count_str - 1))))) 
			|| ' ' || 
			(SELECT (CONCAT ('TYPE: ' || (SELECT routine_type FROM information_schema.routines AS rout
			WHERE routine_type IN ('FUNCTION', 'PROCEDURE') AND routine_body = 'SQL'
			AND routine_schema NOT IN ('information_schema', 'pg_catalog') LIMIT 1 OFFSET (count_str - 1)))));
		END IF;
	END LOOP;
	CLOSE cur;
END;
	$$ LANGUAGE plpgsql;
	
-- CALL s21_show_name_and_type(search_text => 'timestamp');
