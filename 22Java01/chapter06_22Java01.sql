-- *********************************** 第六章 实现复合语句和存储例程 **************************************

USE mysqldb;

-- film表不存在时，创建电影表film
CREATE TABLE IF NOT EXISTS film
(
film_id INT AUTO_INCREMENT PRIMARY KEY,
film_name VARCHAR(50) UNIQUE,
release_date DATE,
film_lang VARCHAR(2),
level INT
);

-- 在film表中插入几条数据
INSERT INTO film(film_name, release_date, film_lang, level) VALUES
('龙猫', '2010-10-01', 'JN', 1),
('借东西的小人阿莉埃蒂', '2012-3-5', 'JN', 3),
('哈尔的移动城堡', '2016-1-1', 'EN', 1),
('千与千寻', '2012-7-24', 'CN', 2),
('风之谷', '2014-5-1', 'EN', 3),
('悬崖上的 金鱼公主', '2014-12-24', 'CN', 2);

SELECT * FROM film;

-- **************************** (一）实现复合语句 *****************************
/*
复合语句：包含其他块的代码块，例如变量的声明，流控制语句，游标以及异常处理，
复合语句可用在其他的数据库对象中，例如：存储过程，函数，触发器和事件等。
复合语句是一起提交给MySQL服务器执行的一组SQL语句。
复合语句执行时，MySQL服务器将所有语句编译为一个可执行单元。
复合语句不能单独执行，只能在存储过程，函数，触发器等数据库对象中使用。
*/

-- **************************** （二）实现存储过程 **********************************
-- 存储过程（stored procedure）是一种在数据库中存储复杂程序，以便在数据库外部调用的一种数据库对象。
-- 存储过程是为了完成特定功能的SQL语句集，经过编译创建并保存在数据库中。
-- 用户可以通过指定存储过程的名字并给定参数来调用执行。

-- 1. 创建一个无参存储过程proc_filmDetail，返回所有的电影信息

-- 存储过程没有参数，也必须在存储过程名后面写上小括号
DELIMITER //		-- 使用DELIMITER修改SQL语句的分隔符，将默认的分隔符;改为//

CREATE PROCEDURE proc_filmDetail ()
BEGIN
	SELECT * FROM film;
END //

DELIMITER ;

-- 调用存储过程
CALL proc_filmDetail;

-- 2. 创建带输入参数的存储过程proc_byLang，带一个输入参数：电影的语言

DELIMITER //		-- 使用DELIMITER修改SQL语句的分隔符，将默认的分隔符;改为//

CREATE PROCEDURE proc_byLang (IN lang CHAR(2))
BEGIN
	SELECT * FROM film WHERE film_lang = lang;
END //

DELIMITER ;


-- 调用存储过程
CALL proc_byLang('CN');

-- 3. 创建带输出参数的存储过程proc_getName
-- 要求根据电影编号，返回电影的名称

DELIMITER //		-- 使用DELIMITER修改SQL语句的分隔符，将默认的分隔符;改为//

CREATE PROCEDURE proc_getName (IN f_id INT, OUT f_name VARCHAR(50))
BEGIN
	SELECT film_name INTO f_name FROM film WHERE film_id = f_id;
END //

DELIMITER ;

-- 调用存储过程
-- @fName是用户定义变量，在整个连接中都有效
CALL proc_getName(2, @fName);

SELECT @fName;

/*
变量:
1. 局部变量
定义: 使用DECLARE定义局部变量,该变量的作用范围只能在BEGIN...END块中.
			局部变量的定义必须在复合语句的开头,并且在任何语句之前.
			可以一次声明多个相同类型的变量.
赋值:
a. 使用SET直接赋值
		如:SET var_name=value;
b. 也可以通过查询将结果赋给变量(SELECT ... INTO ), 这要求查询返回结果必须只有一个.
		如: SELECT col_name INTO var_name ...;
		
2. 用户定义变量
定义: 用户定义变量不需要事先声明,在用的时候直接用"@变量名"使用就可以了.在整个连接中有效.
赋值:
a. 使用SET直接赋值
		如: SET @var_name = value; 或 SET @var_name := value;
b. 也可以通过查询结果赋给变量(SELECT ... INTO ), 这要求查询返回结果必须只有一个.
		如: SELECT col_name INTO @var_name ...;
c. 使用SELECT语句赋值,使用SELECT赋值时必须使用":=",以这种形式赋值的变量不能用作函数的返回值.
		如: SELECT @var_name := value;
*/

-- 4. 创建带输入/输出参数的存储过程proc_getLevel,
-- 根据电影的编号，调整电影等级

DELIMITER //		-- 使用DELIMITER修改SQL语句的分隔符，将默认的分隔符;改为//

CREATE PROCEDURE proc_getLevel (IN f_id INT, INOUT f_level INT)
BEGIN
		-- 使用DECLARE声明局部变量
		-- 局部变量声明一定要放在复合语句的开头
		DECLARE cur_level INT;
		
		SELECT level INTO cur_level FROM film WHERE film_id = f_id;
		
		SET f_level = cur_level + f_level;
	
END //

DELIMITER ;

-- 调用存储过程
SET @level = 2;
CALL proc_getLevel (2, @level);

SELECT @level;

SELECT * FROM film;

-- 6. 查询创建的存储过程
SHOW PROCEDURE STATUS LIKE 'proc%';

-- 7. 删除存储过程
DROP PROCEDURE IF EXISTS proc_byLang;

-- 8. 创建存储过程proc_cn_level
-- 根据调整后的电影等级的范围，显示相应的中文提示
-- 1-3: 一般，4-6：良好，7-10：优秀，其他：其他

DELIMITER //		-- 使用DELIMITER修改SQL语句的分隔符，将默认的分隔符;改为//

CREATE PROCEDURE proc_cn_level (IN f_name VARCHAR(50), IN f_level INT)
BEGIN
	DECLARE info VARCHAR(50);		-- 定义局部变量暂存中文等级
	DECLARE f_id INT;
	
	SELECT film_id INTO f_id FROM film WHERE film_name = f_name;
	
	CALL proc_getLevel(f_id, f_level);
	
	-- if语句
	IF f_level BETWEEN 1 AND 3 THEN
		SET info = '一般';
		ELSE IF f_level BETWEEN 4 AND 6 THEN
			SET info = '良好';
			ELSE IF f_level BETWEEN 7 AND 10 THEN
				SET info = '优秀';
				ELSE SET info = '其他';
			END IF;
		END IF;
	END IF;
	
	SELECT f_level AS '调整后的电影等级', info AS '中文等级';
	
END //

DELIMITER ;

-- 调用存储过程
CALL proc_cn_level('龙猫', 11);

SELECT * FROM film;

-- ************************** （二）实现函数 ***************************

-- 1. 创建函数 func_f_level，根据调用编号，返回电影的中文等级
-- 电影等级：1：优，2：良，3：中，其他：不详

DELIMITER // 

CREATE FUNCTION func_f_level(id INT) RETURNS VARCHAR(50)
BEGIN
	DECLARE zh_level VARCHAR(50);
	DECLARE f_level INT;
	
	SELECT level INTO f_level FROM film WHERE film_id = id;
	
	CASE f_level
		WHEN 1 THEN SET zh_level = '优';
		WHEN 2 THEN SET zh_level = '良';
		WHEN 3 THEN SET zh_level = '中';
		ELSE SET zh_level = '不详';
	END CASE;
	
	RETURN zh_level;	-- 函数必须使用RETURN返回结果
END //

DELIMITER;

-- 调用函数
SELECT film_id, film_name, level, func_f_level(film_id) AS '等级' FROM film;

-- 2. 使用循环，显示film表前n条电影的信息
-- A. while循环，先判断，再执行循环体中的逻辑

DELIMITER //		-- 使用DELIMITER修改SQL语句的分隔符，将默认的分隔符;改为//

CREATE PROCEDURE proc_while (IN num INT)
BEGIN
	DECLARE i INT;
	SET i = 1;
	
	WHILE i <= num DO
		SELECT * FROM film WHERE film_id = i;
		SET i = i + 1;
	END WHILE;
	
END //

DELIMITER ;

-- 调用存储过程
CALL proc_while(3);

-- B. loop循环

DELIMITER //		-- 使用DELIMITER修改SQL语句的分隔符，将默认的分隔符;改为//

CREATE PROCEDURE proc_loop (IN num INT)
BEGIN
	DECLARE i INT;
	SET i = 1;
	
	circle: LOOP
		
		IF i <= num THEN
			SELECT * FROM film WHERE film_id = id;
			SET i = i + 1;
		ELSE
			LEAVE circle;		-- 使用LEAVE语句从循环中退出，相当于Java中的break语句
		END IF;
 
	END LOOP circle;
	
END //

DELIMITER ;

-- 调用存储过程
CALL proc_loop(3);

-- 或者

DELIMITER //		-- 使用DELIMITER修改SQL语句的分隔符，将默认的分隔符;改为//

CREATE PROCEDURE proc_loop1 (IN num INT)
BEGIN
	DECLARE i INT;
	SET i = 1;
	
	circle: LOOP
		
		IF i <= num THEN
			SELECT * FROM film WHERE film_id = id;
			SET i = i + 1;
			
			ITERATE circle;			-- ITERATE语句结束当前循环，继续执行下一次循环，相当于Java中的continue语句
		END IF;
		
		LEAVE circle;		-- 使用LEAVE语句从循环中退出，相当于Java中的break语句
 
	END LOOP circle;
	
END //

DELIMITER ;

-- 调用存储过程
CALL proc_loop1(3);

-- C. repeat循环：先执行循环体内的逻辑，然后再判断条件是否成立

DELIMITER //		-- 使用DELIMITER修改SQL语句的分隔符，将默认的分隔符;改为//

CREATE PROCEDURE proc_repeat (IN num INT)
BEGIN
	DECLARE i INT;
	SET i = 1;
	
	REPEAT
		SELECT * FROM film WHERE film_id = id;
		SET i = i + 1;
	UNTIL i > num
	END WHILE;
	
END //

DELIMITER ;

-- 调用存储过程
CALL proc_repeat(3);

-- ****************************** （三）异常处理 *************************
-- 在运行中发生的错误称为异常

SELECT * FROM film;

INSERT INTO film VALUES(1, '起风了', '2014-05-01', 'EN', 3);

-- ERROR 1062 (23000): Duplicate entry '1' for key 'film.PRIMARY'
-- 1. MySQL错误码(mysql_error_code):MySQL自定义的错误代码,是一个整数值,跟其他数据库不通用.
-- 2. SQLSTATE代码:就是错误码后面的(23000).是一个5位的字符串.是SQL标准化的错误代码.
-- SQLWARNING: 代表所有以01开头的SQLSTATE代码.
-- NOT FOUND: 代表所有以02开头的SQLSTATE代码.
-- SQLEXCEPTION: 代表所有除了01开头和02开头的,其他的SQLSTATE代码

-- 1. 使用DECLARE HANDLER处理异常,异常处理可用于存储例程,函数和触发器等数据库对象中.
-- 语法格式:
-- 		DECLARE 处理方式 HANDLER FOR 错误类型 处理语句;
-- 处理方式:
	-- a. CONTINUE: 遇到异常继续执行后面的语句
	-- b. EXIT: 遇到异常退出复合语句
	-- c. UNDO: 遇到异常撤回之前操作,目前MySQL还不支持
-- 错误类型:
	-- a. SQLSTATE: 字符类型的SQL标准错误代码
	-- b. mysql_error_code: 数值型MySQL的错误代码
	-- c. 错误名称:自定义的错误代码名称
	-- d. SQLWARNING: 代表所有以01开头的SQLSTATE代码.
	-- e. NOT FOUND: 代表所有以02开头的SQLSTATE代码.
	-- f. SQLEXCEPTION: 代表所有除了01开头和02开头的,其他的SQLSTATE代码
-- 处理语句:
-- 可以是简单语句,也可以是复合语句BEGIN...END

-- 处理主键重复异常

DELIMITER //		-- 使用DELIMITER修改SQL语句的分隔符，将默认的分隔符;改为//

CREATE PROCEDURE proc_handle ()
BEGIN
	DECLARE CONTINUE HANDLER FOR SQLSTATE '23000' SELECT '主键重复了';
	
	SET @x = 1;
	INSERT INTO film VALUES(1, '起风了', '2014-05-01', 'EN', 3);
	SET @x = 2;
	INSERT INTO film VALUES(1, '起风了', '2014-05-01', 'EN', 3);
	SET @x = 3;
END //

DELIMITER ;

-- 调用存储过程
CALL proc_handle();

SELECT @x;

-- HANDLER 处理方式：EXIT，发生错误时退出复合语句

DELIMITER //		-- 使用DELIMITER修改SQL语句的分隔符，将默认的分隔符;改为//

CREATE PROCEDURE proc_handle1 ()
BEGIN
	DECLARE EXIT HANDLER FOR SQLSTATE '23000' SELECT '主键重复了';
	
	SET @x = 1;
	INSERT INTO film VALUES(1, '起风了', '2014-05-01', 'EN', 3);
	SET @x = 2;
	INSERT INTO film VALUES(1, '起风了', '2014-05-01', 'EN', 3);
	SET @x = 3;
END //

DELIMITER ;


-- 调用存储过程
CALL proc_handle1;

SELECT @x;

-- 2. 定义条件
-- MySQL为我们提供了一个DECLARE CONDITION 语句来声明一个命名的错误类型.
-- 可以给错误代码或错误状态起一个有意义的名字.
-- 语法格式:
-- DECLARE condition_name CONDITION FOR condition_value
-- condition_value可以是一个类似1062的MySQL错误码,或者是一个SQLSTATE值,
-- 然后 condition_name 就可以代替 condition_value 来使用了.

-- 例如:
-- DECLARE DuplicateKey CONDITION FOR SQLSTATE '23000';
-- DECLARE DuplicateKey CONDITION FOR 1062;


DELIMITER //

CREATE PROCEDURE proc_handle2()
BEGIN
	DECLARE DuplicateKey CONDITION FOR SQLSTATE '23000';	-- 定义条件,即声明一个错误类型
	DECLARE EXIT HANDLER FOR DuplicateKey 			-- 异常处理
	BEGIN
		SELECT 'Duplicate primary key';
		SET @proc_err = -1;
	END;
	
	SET @x = 1;
	INSERT INTO film VALUES(1, '起风了', '2014-05-01', 'EN', 3);
	SET @x = 2;
	INSERT INTO film VALUES(1, '起风了', '2014-05-01', 'EN', 3);
	SET @x = 3;
	
END //

DELIMITER ;

-- 调用存储例程
CALL proc_handle2;
SELECT @proc_err;
SELECT @x;

-- 3. 使用SIGNAL手动返回一个错误
-- 要求用户插入的电影等级必须大于0,否则的话报错

DELIMITER //

CREATE PROCEDURE proc_signal(IN f_name VARCHAR(50), IN f_date DATE, IN f_lang CHAR(2), IN f_level INT)
BEGIN
	IF f_level <= 0 THEN
		SIGNAL SQLSTATE '45000' SET message_text = '电影等级必须大于0';
	ELSE
		INSERT INTO film(film_name, release_date, film_lang, level)
		VALUES(f_name, f_date, f_lang, f_level);
	END IF;
END //

DELIMITER ;


SELECT * FROM film;

-- 调用存储例程
CALL proc_signal('狸猫变形', '2011-11-11', 'JN', -1);

CALL proc_signal('狸猫变形', '2011-11-11', 'JN', 7);

DELETE FROM film WHERE film_id = 7;





