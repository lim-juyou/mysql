-- ********** 第五章章 实现索引和视图 **********

-- ********** 一、创建和管理索引 **********
USE mysqldb;

-- ************************* (一）创建表时指定索引 **************************
/*
创建菜单表menu
menu_id int 主键
menu_name varchar(30) 值唯一
description varchar(100)  全文索引
price int   常规索引*/

DROP TABLE menu;

CREATE TABLE IF NOT EXISTS menu (
menu_id INT PRIMARY KEY, 											-- 创建主键约束自动创建主键索引
menu_name VARCHAR(30) NOT NULL,
CONSTRAINT uk_menu_name UNIQUE (menu_name),		-- 创建唯一约束自动创建唯一索引
description VARCHAR(100),
FULLTEXT INDEX ft_description (description), 	-- FULLTEXT [INDEX] 全外索引名 (索引列列表)
price INT,
INDEX ix_price (price)												-- INDEX | KEY 常规索引名 (索引列列表)
);

-- 查看表中的索引信息
SHOW INDEXES FROM menu;

/*创建点餐表order
order_id int 主键
food_id int 与菜单表的主键进行关联
order_date date类型
*/
CREATE TABLE IF NOT EXISTS order_food(
order_id INT PRIMARY KEY,
food_id INT,
CONSTRAINT fk_food_id FOREIGN KEY (food_id) REFERENCES menu(menu_id),	-- 创建外键约束时自动创建外键索引
order_date date
);

-- 查看表的索引信息
SHOW INDEXES FROM order_food;

-- **************************(二)删除索引*****************
-- DROP INDEX 索引名 ON 表名 | ALTER table 表名 DROP INDEX 索引名
-- 1. 删除order_food表的外键索引
-- 外键索引不能直接根据索引名字来删除索引，需要先删除外键约束后，才能删除外键索引。
-- DROP INDEX fk_food_id ON order_food;

-- a、删除外键约束，删除外键约束时不会自动删除外键索引
ALTER TABLE order_food
DROP FOREIGN KEY fk_food_id;

-- 查询表所具有的约束 
SELECT *
FROM information_schema.TABLE_CONSTRAINTS
WHERE table_name = 'order_food';

-- 查看表的索引信息
SHOW indexes FROM order_food;

-- b、删除外键索引
DROP INDEX fk_food_id ON order_food;
-- 或者使用
ALTER TABLE order_food DROP INDEX fk_food_id;

-- 2、删除menu表的全文索引
DROP INDEX ft_description ON menu;
-- 或者使用
ALTER TABLE menu DROP INDEX ft_description;

-- 3、删除menu表的常规索引
DROP INDEX ix_price ON menu;
-- 或者使用
ALTER TABLE menu DROP INDEX ix_price;

-- 4、删除menu表的唯一索引
SELECT *
FROM information_schema.TABLE_CONSTRAINTS
WHERE table_name = 'menu';

SHOW INDEXES FROM menu;

-- 删除唯一约束
-- 语法错误
-- ALTER TABLE menu
-- DROP UNIQUE uk_menu_name;

-- 删除唯一索引时，唯一约束会被自动删除
DROP INDEX uk_menu_name ON menu;
-- 或者使用
ALTER TABLE menu DROP INDEX uk_menu_name;

-- 5. 删除menu表的主键索引
-- 删除主键索引会自动删除主键约束
DROP INDEX `PRIMARY` ON menu;
-- 或者使用
ALTER TABLE menu DROP INDEX `PRIMARY`;

-- 查看表的约束
SELECT * FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'menu';

-- 查看表的约束
SELECT * FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'order_food';

-- 查看表中的索引信息
SHOW INDEX FROM order_food;

-- 删除主键约束
ALTER TABLE order_food
DROP PRIMARY KEY;

/*
总结:
1. 删除主键约束会自动删除主键索引;删除主键索引也会自动删除主键约束.
2. 删除外键约束不会自动删除外键索引.
不能直接删除外键索引,删除外键索引前,必须先删除外键约束,然后才能删除外键索引.
3. 不能直接删除唯一约束,而要使用删除唯一索引的语法,删除唯一索引就是删除唯一约束.
4. 常规索引和全文索引可以直接删除.
删除索引的两种语法:
a. DROP INDEX 索引名 ON 表名 
b. ALTER TABLE 表名 DROP INDEX 索引名
*/

-- ************************** (三）在现有表上创建索引 ****************************
-- ALTER TABLE 表名 ADD INDEX | KEY 索引名(索引列表) 			-- 常规索引
-- ALTER TABLE 表名 ADD FULLTEXT [INDEX] 索引名(索引列表)	-- 全文索引
-- CREATE INDEX | UNIQUE | FULLTEXT INDEX 索引名 ON 表名(索引列列表)

SHOW INDEX FROM menu;
SHOW INDEX FROM order_food;

-- 1. 给menu表的menu_id列创建主键索引，添加主键约束就是添加主键索引
ALTER TABLE menu
ADD PRIMARY KEY(menu_id);

-- 2. 给menu表的menu_name列添加唯一索引
-- 方式一：通过给表添加唯一约束来自动添加唯一索引
ALTER TABLE menu
ADD CONSTRAINT uk_menu_name1 UNIQUE(menu_name);

-- 方法二： 通过CREATE UNIQUE INDEX 直接添加
CREATE UNIQUE INDEX uk_menu_name2 ON menu(menu_name);

-- 3. 创建常规索引
-- 给menu表添加菜单分类列
ALTER TABLE menu
ADD COLUMN type VARCHAR(20);

DESC menu;

-- 如果用户根据menu表点餐时，经常会根据菜品的分类和价格进行检索菜品
SELECT * FROM menu
WHERE type = 'beer' AND price < 100;

-- 可以通过索引加快查询速度
-- 创建常规组合索引
ALTER TABLE menu ADD INDEX c_key(type, price);
-- 或
CREATE INDEX c_key(type, price) ON menu;

-- 4. 给menu表的description列创建全文索引
ALTER TABLE menu ADD FULLTEXT INDEX ft_description(description);
-- 或
CREATE FULLTEXT INDEX ft_description(description) ON menu;


-- 5. 给order_food表的food_id列添加索引
-- 即添加外键约束
ALTER TABLE order_food
ADD CONSTRAINT fK_food_id FOREIGN KEY (food_id) REFERENCES menu(menu_id);

/*
总结:
1. 主键索引通过主键约束创建
2. 外键索引通过外键约束创建
3. 唯一索引即可以通过唯一约束创建,也可以通过CREATE UNIQUE INDEX创建
创建唯一约束会自动创建唯一索引,创建唯一索引也会自动创建唯一约束.
4. 创建常规索引和全文索引的语法:
-- ALTER TABLE 表名 ADD INDEX | KEY 索引名(索引列表) 			-- 常规索引
-- ALTER TABLE 表名 ADD FULLTEXT [INDEX] 索引名(索引列表)	-- 全文索引
-- CREATE INDEX | FULLTEXT INDEX 索引名 ON 表名(索引列列表)
*/

-- ************************ 二 实现视图 *****************************
-- 创建学生表
CREATE TABLE IF NOT EXISTS Student
(
rollno CHAR(4) NOT NULL,
name VARCHAR(20) NOT NULL,
addr VARCHAR(50)
);

-- 插入数据
INSERT INTO Student VALUES
('S001', 'Allen', 'qdu'),
('S002', 'Jhon', NULL),
('S003', 'David', 'qdu'),
('S004', 'Stefen', NULL),
('S005', 'Steve', 'qdu');

-- 创建成绩表
CREATE TABLE IF NOT EXISTS Marks
(
rollno CHAR(4) NOT NULL,
rdbms INT,
math INT
);

-- 插入数据
INSERT INTO Marks VALUES
('S001', 98, 76),
('S002', 67, 64),
('S003', 76, 96),
('S006', 60, 69);

SELECT * FROM Student;
SELECT * FROM Marks

-- ******************** （一）创建视图 ***************************
-- 1. 创建视图
CREATE VIEW v_all
AS
SELECT * FROM student;

-- 显示所有的视图和表
SHOW TABLES;

-- 显示视图和表的信息
SHOW TABLE STATUS FROM mysqldb LIKE 'v_all';
SHOW TABLE STATUS FROM mysqldb LIKE 'student';

SELECT * FROM v_all;

-- 2. 创建视图时，自定义结果集中显示列的名称，效果和给列起别名类似
CREATE VIEW v_def(sno, sname, saddr)
AS
SELECT * FROM student;

SELECT * FROM v_def;

-- 3. 定义一个视图，查询marks表中math成绩大于75的记录
CREATE VIEW v_math
AS
SELECT * FROM marks WHERE math > 75;

SELECT * FROM v_math;

-- 查询视图v_math，查询rdbms成绩大于90的记录
-- 查询带有WHERE子句的视图时，再次使用WHERE子句过滤数据
-- 此情况下，会将两个过滤条件进行合并，返回最终过滤的结果
SELECT * FROM v_math WHERE rdbms > 90;
-- 相当于
SELECT * FROM marks WHERE math > 75 AND rdbms > 90;

-- 4. 修改视图
-- CREATE OR REPLACE VIEW: 创建视图时，如果数据库中已经存在同名视图，
-- 就使用新视图替换旧视图，否则就创建新视图
CREATE OR REPLACE VIEW v_math
AS 
SELECT * FROM marks WHERE rdbms > 60;

SELECT * FROM v_math;

-- 5. 创建一个视图v_math_order，查询marks表中全部记录，结果按照rdbms降序排序
-- 创建自带ORDER BY子句的视图
CREATE VIEW v_math_order
AS
SELECT * FROM marks ORDER BY rdbms DESC;

SELECT * FROM v_math_order;

-- 查询视图v_math_order视图，要求按照math升序排序
-- 当视图定义里自带ORDER BY子句时，我们查询视图再次指定ORDER BY，
-- 那么视图定义中的ORDER BY就会被舍弃，以查询中的为准
SELECT * FROM v_math_order ORDER BY math;

-- 6. 创建一个视图v_stu_score，查询有成绩的学生的学号，姓名，rdbms成绩，math成绩
SELECT * FROM student;
SELECT * FROM marks;

-- 视图可以简化复杂查询的执行

CREATE VIEW v_stu_score
AS
SELECT rollno, name, rdbms, math
FROM student s JOIN marks m
USING (rollno);

SELECT * FROM v_stu_score;

-- 7. 创建一个视图v_avg，查询rdbms，math的平均分
CREATE VIEW v_avg(rdbms_avg, math_avg)
AS
SELECT AVG(rdbms), AVG(math) FROM mark;

SELECT * FROM v_avg;

-- 8. 创建一个视图v_addr_avg，显示不同地址学生的math成绩的平均分和地址
CREATE VIEW v_addr_avg(addr, math_avg)
AS
SELECT addr, AVG(math)
FROM student s JOIN marks m
USING(rollno)
GROUP BY addr;

SELECT * FROM v_addr_avg;

-- 9. 基于视图v_addr_avg，创建一个视图v_v_math_best，查询math平均分大于85的学生的地址
CREATE VIEW v_v_math_best
AS
SELECT * FROM v_addr_avg WHERE math_avg > 85;

SELECT * FROM v_v_math_best;

-- 10. 创建视图基于的底层表或其他视图必须存在，如果不存在，直接提示表不存在
CREATE VIEW v_test
AS
SELECT * FROM aa;

-- 11. 使用嵌套子查询创建视图v_sub_sel，查询math创建最高的学生的姓名

-- *************************** （二）更新视图 *************************
-- A. 在视图上执行INSERT操作
-- 1. 在视图v_def上执行插入操作，要求插入学生的学号和地址两列信息('S008', 'HNU')
SELECT * FROM v_def;

-- 插入的数据没有包含表中所有的NOT NULL列，所以提示出错
INSERT INTO v_def(sno, saddr) VALUES ('S008', 'HNU');
-- 相当于下面的语句
INSERT INTO student(rollno, addr) VALUES ('S008', 'HNU');

-- 2. 在视图v_def上执行插入操作，要求插入学生的学号，姓名和地址('S009', 'lily', 'HNU')
INSERT INTO v_def(sno, sname, saddr) VALUES ('S009', 'lily', 'HNU');

SELECT * FROM student;

-- 3. 在视图v_avg上执行插入操作，要求插入rdbms，math的平均分，分别是80，90
SELECT * FROM v_avg;

-- 不能插入聚合函数值，提示出错
INSERT INTO v_avg VALUES (80, 90);

-- 4. 在视图v_stu_score上执行插入操作，插入一行数据('S010', 'Thurs', 100, 100)
SELECT * FROM v_stu_score;

-- 插入报错，插入操作只能影响一个底层表
INSERT INTO v_stu_score (rollno, name, rdbms, math) VALUES ('S010', 'Thurs', 100, 100);
-- 如果只影响一个底层表，可以执行插入
INSERT INTO v_stu_score (rollno, name) VALUES ('S010', 'Thurs');

SELECT * FROM student;

-- B. 在视图上执行UPDATE操作
-- 1. 更新视图v_math，将学号是S001的math成绩改为70
SELECT * FROM v_math;

UPDATE v_math SET math = 70 WHERE rollno = 'S001';

-- 2. 更新视图v_stu_score，将学号是S002的学生姓名改为Joe，math成绩改为80
SELECT * FROM v_stu_score;

-- 出错：因为不能影响多张表
UPDATE v_stu_score SET name = 'Joe', math = 80 WHERE rollno = 'S002';
-- 成功，将上一条语句拆分成两条语句
UPDATE v_stu_score SET name = 'Joe' WHERE rollno = 'S002';
UPDATE v_stu_score SET math = 80 WHERE rollno = 'S002';

-- 3. 更新视图v_addr_avg，将math平均分为80的地址改为HNU
SELECT * FROM v_addr_avg;

-- 出错：不能聚合和分组产生的数据
UPDATE v_addr_avg SET addr = 'HNU' WHERE math_avg = 80;

-- C. 在视图上执行DELETE操作
-- 1. 对视图v_stu_score执行删除操作，删除学号是S002的记录
SELECT * FROM v_stu_score;

DELETE FROM v_stu_score WHERE rollno = 'S002';

-- 2. 对视图v_addr_avg，删除地址为NULL的记录
SELECT * FROM v_addr_avg;

-- 删除出错，因为视图中包含分组生成的列和聚合函数生成的列
DELETE FROM v_addr_avg WHERE addr IS NULL;

-- 3. 对视图v_math_order，删除学号为S006的记录

DELETE FROM v_math_order WHERE rollno = 'S006';

SELECT * FROM marks;

/*
结论:
通过视图更新底层表的数据,包含:DELETE, UPDATE, INSERT
1. 不能违反底层表的任何约束
2. 不能同时更新多个底层表的数据
3. 不能更新分组产生的列和聚合函数产生的列
*/

-- ************************* （三）管理视图 ***************************
-- A. 修改视图
-- 修改视图v_stu_score，增加地址列信息
SELECT * FROM v_stu_score;

ALTER VIEW v_stu_score
AS
SELECT rollno, name, addr, rdbms, math
FROM student s JOIN marks m
USING (rollno);

-- B. 删除视图
SHOW TABLES;

-- 删除视图v_math_order
DROP VIEW IF EXISTS v_math_order;
-- 删除视图就是删除视图的定义和分配给它的权限，对底层表没有影响
SELECT * FROM marks;



