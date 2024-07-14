-- ****************** 第二章 管理数据库和表 **********************

/*
（1）SQL的规则
- SQL 可以写在一行或者多行。为了提高可读性，各子句可以分行写，
- 必要时使用缩进。每条命令以;结束。

（2）SQL的规范
- MySQL在Windows环境下是大小写不敏感的
- MySQL在Linux环境下是大小写敏感的
		- 数据库名、表名、表的别名、变量名是严格区分大小写
		- 关键字、函数名、列名、列的别名是忽略大小写的
- 推荐采用统一的书写规范：
		- 数据库名、表名、表别名、字段名、字段别名等都小写
		- SQL 关键字、函数名、变量名等都大写
*/

-- （3） MySQL的三种注释的方式
-- 单行注释：-- 注释文字（--后面必须包含一个空格）
-- 单行注释：#注释文字（MySQL特有的方式）
-- 多行注释：/* 注释文字 */

/*
（4）标识符命名规则
a. 数据库名、表名不得超过30个字符，变量名限制为29个字符
b. 只能包含A-Z，a-z，0-9，_共63个字符，并且数字不能作为首字符
*/

-- ************************* 1. 创建和管理数据库 ************************
-- CREATE DATABASE [IF NOT EXISTS] <database_name>
--     [[DEFAULT] CHARACTER SET <character_set_name>]
--     [[DEFAULT] COLLATE <collation_name>]

-- 1.1 创建数据库mydb1
CREATE DATABASE IF NOT EXISTS mydb1;

-- 1.2 显示MySQL服务器中所有数据库的列表
SHOW DATABASES;

-- 1.3 使用（切换到）数据库mydb1
USE mydb1;

SHOW TABLES;

-- 1.4 （可选）创建数据库mydb2，并且指定字符集big5，字符序big5_chinese_ci
CREATE DATABASE IF NOT EXISTS mydb2
CHARACTER SET big5
COLLATE big5_chinese_ci;

-- MySQL 8.x 的默认字符集utf8mb4，默认字符序utf8mb4_0900_ai_ci
-- 查看所有字符集（了解）
SHOW CHARACTER SET;

-- 查看所有的字符序（了解）
SHOW COLLATION;

-- 字符序COLLATE（了解）
-- COLLATE带有_ci后缀，这是Case Insensitive的缩写，即大小写无关
-- COLLATE带有_cs后缀，则是Case Sensitive，即大小写敏感的。
-- COLLATE带有_bin后缀，就是直接将所有字符看作二进制串，显然它是区分大小写的。

-- 1.5 （可选）将数据库mydb2的字符集改为utf8mb4，字符序改为utf8mb4_0900_ai_ci
ALTER DATABASE mydb2
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

USE mydb2;
-- 查看当前数据库的字符集（了解）
SHOW VARIABLES LIKE 'character%';
-- 查看当前数据库的字符序（了解）
SHOW VARIABLES LIKE 'collation%';

-- 1.6 删除数据库mydb2
DROP DATABASE IF EXISTS mydb2;

-- *********************** 2. 创建和管理表 *****************************
-- CREATE [TEMPORARY] TABLE [IF NOT EXISTS][ <table_name> (<table_element> [{, <table_element>}...])[ENGINE = { MEMORY | INNODB | MERGE | MRG_MYISAM | MYISAM}]

-- 2.1 创建表
-- 创建表emp，包含以下属性：
-- emp_id 整数类型
-- emp_name 最多保存20个字符
-- salary 小数类型
-- birthday 日期类型

CREATE TABLE IF NOT EXISTS emp
(
emp_id INT,
emp_name VARCHAR(20),
salary DOUBLE,
birthday DATE
);

-- 查看当前数据库中的所有表
SHOW TABLES;

-- 查看表结构
-- 可以DESCRIBE/DESC语句查看表结构
DESC emp;
-- 还可以是SHOW CREATE TABLE 语句查看表结构
SHOW CREATE TABLE emp;

-- 浮点类型
-- 浮点类型有个缺陷，就是不精确
-- 在编程时，如果用到浮点数，要特别注意误差问题。因为浮点数是不准确的，所以，
-- 我们要避免使用"="来判断两个浮点数是否相等。

CREATE TABLE test_double
(
f1 DOUBLE
);

INSERT INTO test_double
VALUES (0.47), (0.44), (0.19);

SELECT * FROM test_double;

SELECT SUM(f1) FROM test_double;
SELECT SUM(f1)=1.1, 1.1=1.1 FROM test_double;

-- 定点数类型
-- a. MySQL中的定点数类型只有DECIMAL一种类型
-- 使用DECIMAL(M,D)的方式表示高精度小数。
-- 其中，M被称为精度，D被称为标度。0<=M<=65, 0<=D<=30, D<M
-- 例如，定义DECIMAL(5,2)，表示该数据取值范围：-999.99~999.99
-- b. 定点数在MySQL内部是以字符串的形式存储的，这就决定了它一定是精确的。
-- c. 当DECIMAL类型不指定精度和标度时，其默认为DECIMAL(10,0)。
-- 当数据的标度超出范围时，则会进行四舍五入。
-- 当数据的精度超出范围时，则会报错。

CREATE TABLE test_decimal(
f1 DECIMAL,
f2 DECIMAL(5,2)
);

DESC test_decimal;

INSERT INTO test_decimal(f1, f2)
VALUES(123.123, 123.456);

-- 报错
INSERT INTO test_decimal(f2)
VALUES(1234.34);

SELECT * FROM test_decimal;

-- 把test_double表中字段'f1'的数据类型改为DECIMAL(5,2):
ALTER TABLE test_double
MODIFY f1 DECIMAL(5,2);

DESC test_double;

SELECT SUM(f1) FROM test_double;
SELECT SUM(f1)=1.1, 1.1=1.1 FROM test_double;

-- 日期和时间类型
-- DATETIME类型以 YYYY-MM-DD HH:MM:SS 格式或 YYYYMMDDHHMMSS 格式的字符串

CREATE TABLE test_datetime(
dt DATETIME
);

INSERT INTO test_datetime
VALUES ('2024-01-01 10:10:10'), ('20240101101010');

INSERT INTO test_datetime
VALUES (20240101101010);

SELECT * FROM test_datetime;

-- 2.2 更改表 ALTER TABLE 
CREATE TABLE IF NOT EXISTS dept (
deptno INT,
dname VARCHAR(15),
loc VARCHAR(20)
);

DESC dept;

-- (1) 添加约束(主键约束和外键约束)
ALTER TABLE dept
ADD PRIMARY KEY (deptno);

-- (2) 添加列
-- 语法：ALTER TABLE 表名 ADD [COLUMN] 字段名 字段类型 [FIRST | AFTER 字段名];
ALTER TABLE dept
ADD job_id VARCHAR(15) AFTER dname;

-- (3) 修改列
-- ALTER: 只能更改列的默认值
-- MODIFY: 可以更改列的定义，但不能更改列名称
-- CHANGE: 可以重命名列或者修改列的定义

ALTER TABLE dept
ALTER COLUMN loc SET DEFAULT 'HNU';

ALTER TABLE dept
MODIFY COLUMN job_id CHAR(20);

ALTER TABLE dept
CHANGE COLUMN deptno dno INT;

DESC dept;

-- (4) 删除列
ALTER TABLE dept
DROP COLUMN job_id;

-- (5) 重命名表
ALTER TABLE dept
RENAME TO departments;

SHOW TABLES;

-- 2.3 操作表数据
CREATE TABLE IF NOT EXISTS emp1(
id INT PRIMARY KEY,
name VARCHAR(15),
hire_date DATE,
salary DECIMAL(10,2)
);

SELECT * FROM emp1;

-- (1) 添加数据
-- a. 不指明添加的字段
INSERT INTO emp1
VALUES (1, 'Tom', '2000-12-12', 3400);
-- 错误
INSERT INTO emp1
VALUES (2, 3400, '2000-12-21', 'Jerry');

-- b. 指明要添加的字段（推荐）
INSERT INTO emp1(id, hire_date, salary, name)
VALUES (2, '1999-09-09', 4000, 'Jerry');

-- 指定部分要添加的字段
-- 添加数据时可以不指定的字段：自增列、允许为NULL、有默认值、计算列
INSERT INTO emp1 (id, salary, name)
VALUES(3, 4500, 'SHK');

-- c. 同时插入多条数据（推荐）
INSERT INTO emp1(id, name, salary) VALUES
(4, 'Jim', 5000),
(5, 'Tiger', 5500);

SELECT * FROM emp1;

-- d. 使用REPLACE语句
REPLACE INTO emp1(id, name, hire_date, salary) VALUES(3, 'Anna', '2022-10-10', 5000);

-- （2）更新数据
-- 使用WHERE 子句指定需要更新的数据
-- 否则表中的所有数据都将被更新
UPDATE emp1 SET hire_date = '2024-04-15' WHERE id = 4;

SELECT * FROM emp1;

-- (3) 复制数据
-- a. 将数据复制到现有表
CREATE TABLE IF NOT EXISTS emp2(
id INT PRIMARY KEY,
name VARCHAR(15),
salary DECIMAL(10,2)
);

INSERT INTO emp2
SELECT id, name, salary FROM emp1;
-- 或
REPLACE INTO emp2
SELECT id, name, salary FROM emp1;

SELECT * FROM emp2;

-- b. 将数据复制到新表
CREATE TABLE emp3
SELECT id, name, salary FROM emp1;

SELECT * FROM emp3;

-- (4) 删除数据
-- DELETE 语句
-- 使用WHERE子句删除指定的记录
DELETE FROM emp3 WHERE id = 1;

-- 如果省略WHERE子句，则表中的全部数据将被删除
DELETE FROM emp3;

-- TRUNCATE 语句：用于删除表中所有记录
TRUNCATE TABLE emp2;

SELECT * FROM emp2;

-- 2.4 删除表
SHOW TABLES;

DROP TABLE emp2;
DROP TABLE emp3;

-- 3. MySQL8新特性：计算列
-- 计算列：简单来说就是某一列的值是通过别的列计算得来的。
CREATE TABLE tb1(
a INT,
b INT,
c INT GENERATED ALWAYS AS (a + b) VIRTUAL
);

INSERT INTO tb1(a, b) VALUES(100, 200);

SELECT * FROM tb1;

UPDATE tb1 SET a = 500;










