-- MySQL约束

/*
1. 基础知识
1.1 为什么需要约束？ 为了保证数据的完整性！

1.2 什么叫约束？对表中字段的限制。

1.3 约束的分类：

角度1：约束的字段的个数
单列约束 vs 多列约束

角度2：约束的作用范围

列级约束：将此约束声明在对应字段的后面
表级约束：在表中所有字段都声明完，在所有字段的后面声明的约束

角度3：约束的作用（或功能）

① not null (非空约束)
② unique  (唯一性约束)
③ primary key (主键约束)
④ foreign key (外键约束)
⑤ check (检查约束)
⑥ default (默认值约束)

1.4 如何添加/删除约束？

CREATE TABLE时添加约束

ALTER TABLE 时增加约束、删除约束
*/

-- 2. 如何查看表中的约束
DESC test1;

SELECT * FROM information_schema.TABLE_CONSTRAINTS
WHERE table_name = 'test1';

CREATE DATABASE IF NOT EXISTS dbtest;
USE dbtest;

-- 3. NOT NULL(非空约束）
-- 3.1 在CREATE TABLE 时添加约束
CREATE TABLE test1(
id INT NOT NULL, 	-- 列级约束
last_name VARCHAR(15) NOT NULL,
email VARCHAR(25),
salary DECIMAL(10,2)
);

DESC test1;

INSERT INTO test1(id, last_name, email, salary)
VALUES(1,'Tom','tom@126.com',3400);
-- 错误：Column 'last_name' cannot be null
INSERT INTO test1(id, last_name, email, salary)
VALUES(2,NULL,'tom@126.com',3400);
-- 错误：Column 'id' cannot be null
INSERT INTO test1(id, last_name, email, salary)
VALUES(NULL,'Jerry','jerry@126.com',3400);
-- 错误：Field 'last_name' doesn't have a default value
INSERT INTO test1(id,email)
VALUES(2,'abc@126.com');

SELECT * FROM test1;

-- 错误：Column 'last_name' cannot be null
UPDATE test1
SET last_name = NULL WHERE id = 1;

UPDATE test1
SET email = NULL WHERE id = 1;

-- 3.2 在ALTER TABLE 时添加约束
DESC test1;

ALTER TABLE test1
MODIFY email VARCHAR(25) NOT NULL;

UPDATE test1 SET email = 'abc@126.com' WHERE id = 1;

-- 3.3 在ALTER TABLE 时删除约束
ALTER TABLE test1
MODIFY email VARCHAR(25);

-- 4. unique（唯一性约束）
-- 4.1 在CREATE TABLE 时添加约束
CREATE TABLE test2(
id INT UNIQUE,	-- 列级约束
last_name VARCHAR(15),
email VARCHAR(25),
salary DECIMAL(10,2),
-- 表级约束
CONSTRAINT uk_test2_email UNIQUE(email)
);

-- 查看约束
DESC test2;

SELECT * FROM information_schema.TABLE_CONSTRAINTS
WHERE table_name = 'test2';

INSERT INTO test2(id, last_name, email, salary)
VALUES(1, 'Tom', 'tom@126.com', 4500);
-- 错误：Duplicate entry '1' for key 'test2.id'
INSERT INTO test2(id, last_name, email, salary)
VALUES(1, 'Tom1', 'tom1@126.com', 4600);
-- 错误：Duplicate entry 'tom@126.com' for key 'test2.uk_test2_email'
INSERT INTO test2(id, last_name, email, salary)
VALUES(2, 'Tom1', 'tom@126.com', 4600);

INSERT INTO test2(id, last_name, email, salary)
VALUES(2, 'Tom1', NULL, 4600);

INSERT INTO test2(id, last_name, email, salary)
VALUES(3, 'Tom2', NULL, 4600);

SELECT * FROM test2;

-- 4.2 在ALTER TABLE 时添加约束
DESC test2;

-- 方式一：
ALTER TABLE test2
MODIFY salary DECIMAL(10,2) UNIQUE;

UPDATE test2 SET salary = 4700 WHERE id = 3;

-- 方式二：
ALTER TABLE test2
ADD CONSTRAINT uk_test2_lastname UNIQUE(last_name);

-- 4.3 复合的唯一约束
CREATE TABLE user(
id INT,
name VARCHAR(15),
password VARCHAR(25),
-- 表级约束
CONSTRAINT uk_user_name_pwd UNIQUE(name, password)
);

INSERT INTO user
VALUES(1, 'Tom', 'abc');

INSERT INTO user
VALUES(2, 'Tom', 'abc');

INSERT INTO user
VALUES(3, 'Tom1', 'abc');

SELECT * FROM user;

-- 4.4 删除唯一性约束
-- 删除唯一性约束只能通过删除唯一索引的方式删除
SELECT * FROM information_schema.TABLE_CONSTRAINTS
WHERE table_name = 'test2';

ALTER TABLE test2
DROP INDEX uk_test2_lastname;

ALTER TABLE test2
DROP INDEX uk_test2_email;

-- 5. primary key （主键约束）
-- 5.1 在CREATE TABLE 时添加约束
-- 错误：Multiple primary key defined
CREATE TABLE test3(
id INT PRIMARY KEY,	-- 列级约束
last_name VARCHAR(15) PRIMARY KEY,
salary DECIMAL(10,2),
email VARCHAR(25)
);

CREATE TABLE test4(
id INT PRIMARY KEY,	-- 列级约束
last_name VARCHAR(15),
salary DECIMAL(10,2),
email VARCHAR(25)
);

CREATE TABLE test5 (
id INT,
last_name VARCHAR(15),
salary DECIMAL(10,2),
email VARCHAR(25),
-- 表级约束
CONSTRAINT pk_test5_id PRIMARY KEY (id)	-- 没有必要起名字
);

SELECT * FROM information_schema.TABLE_CONSTRAINTS
WHERE table_name = 'test5';

INSERT INTO test4 (id, last_name, salary, email)
VALUES(1,'Tom',4500,'tom@126.com');
-- 错误：Duplicate entry '1' for key 'test4.PRIMARY'
INSERT INTO test4 (id, last_name, salary, email)
VALUES(1,'Tom',4500,'tom@126.com');
-- 错误：Column 'id' cannot be null
INSERT INTO test4 (id, last_name, salary, email)
VALUES(NULL,'Tom',4500,'tom@126.com');

SELECT * FROM test4;

-- 复合主键
CREATE TABLE user1(
id INT,
name VARCHAR(15),
password VARCHAR(25),
-- 表级约束
PRIMARY KEY(name, password)
);

INSERT INTO user1
VALUES(1, 'Tom', 'abc');
-- 错误：Duplicate entry 'Tom-abc' for key 'user1.PRIMARY'
INSERT INTO user1
VALUES(2, 'Tom', 'abc');

INSERT INTO user1
VALUES(3, 'Tom1', 'abc');
-- 错误：Column 'name' cannot be null
INSERT INTO user1
VALUES(4, NULL, 'abc');

SELECT * FROM user1;

-- 5.2 在ALTER TABLE时添加约束
CREATE TABLE test6 (
id INT,
last_name VARCHAR(15),
salary DECIMAL(10,2),
email VARCHAR(25)
);

DESC test6;

ALTER TABLE test6
ADD PRIMARY KEY (id);

-- 5.3 删除主键约束
ALTER TABLE test6
DROP PRIMARY KEY;

-- 6. 自增长列：AUTO_INCREMENT
-- 6.1 在CREATE TABLE时添加
CREATE TABLE test7(
id INT PRIMARY KEY AUTO_INCREMENT,
last_name VARCHAR(15)
);

-- 一旦在字段上声明了AUTO_INCREMENT，则在添加数据时，
-- 就不需要给该字段赋值了。
INSERT INTO test7(last_name)
VALUES ('Tom');

SELECT * FROM test7;

-- 当我们向自增列的字段添加0或NULL时，
-- 实际上会字段的往上添加指定的字段的数值
INSERT INTO test7(id,last_name)
VALUES (0, 'Tom');

INSERT INTO test7(id,last_name)
VALUES (NULL, 'Tom');

INSERT INTO test7(id,last_name)
VALUES (10, 'Tom');

-- 7. foreign key （外键约束）
-- 7.1 在CREATE TABLE 时添加

-- 主表和从表；父表和子表

-- 先创建主表
CREATE TABLE dept1(
dept_id INT,
dept_name VARCHAR(15)
);

-- 然后在创建从表
CREATE TABLE emp1(
emp_id INT PRIMARY KEY AUTO_INCREMENT,
emp_name VARCHAR(15),
department_id INT,
-- 表级约束
CONSTRAINT fk_emp1_dept_id FOREIGN KEY(department_id) REFERENCES dept1(dept_id)
);

-- 上述操作报错，因为主表中的dept_id上没有主键约束或唯一性约束。
-- 添加主键约束
ALTER TABLE dept1
ADD PRIMARY KEY(dept_id);

DESC emp1;
SELECT * FROM information_schema.TABLE_CONSTRAINTS
WHERE table_name = 'emp1';

-- 7.2 演示外键的效果
-- 添加失败
INSERT emp1(emp_id, emp_name, department_id)
VALUES (1001, 'Tom', 10);

-- 需要先在dept1表中添加了10号部门以后
INSERT INTO dept1
VALUES(10, 'IT');

-- 才可以在从表中添加10号部门的员工
INSERT emp1(emp_id, emp_name, department_id)
VALUES (1001, 'Tom', 10);

SELECT * FROM dept1;
SELECT * FROM emp1;

DELETE FROM dept1 WHERE dept_id = 10;

UPDATE dept1 SET dept_id = 20 WHERE dept_id = 10;

-- 7.3 在ALTER TABLE 时添加外键约束
CREATE TABLE dept2(
dept_id INT PRIMARY KEY,
dept_name VARCHAR(15)
);

CREATE TABLE emp2(
emp_id INT PRIMARY KEY AUTO_INCREMENT,
emp_name VARCHAR(15),
department_id INT
);

ALTER TABLE emp2
ADD CONSTRAINT fk_emp2_dept_id FOREIGN KEY (department_id) REFERENCES dept2(dept_id);

SELECT * FROM information_schema.TABLE_CONSTRAINTS
WHERE table_name = 'emp2';

-- 删除外键约束
ALTER TABLE emp2
DROP FOREIGN KEY fk_emp2_dept_id;

-- 7.5 级联更新和级联删除(了解)
-- CASCADE方式：在主表上UPDATE/DELETE记录时，会同步UPDATE/DELETE从表的匹配记录。
-- SET NULL方式：在主表上UPDATE/DELETE记录时，将从表上匹配记录的列设为NULL。
-- NO ACTION方式：如果子表中有匹配的记录，则不允许对主表对应的数据进行UPDATE/DELETE操作
-- RESTRICT方式：同NO ACTION方式

-- 演示
CREATE TABLE dept(
dept_id INT PRIMARY KEY,
dept_name VARCHAR(15)
);

DROP TABLE emp;

CREATE TABLE emp(
emp_id INT PRIMARY KEY AUTO_INCREMENT,
emp_name VARCHAR(15),
department_id INT
);

INSERT INTO dept VALUES(1001,'教学部');
INSERT INTO dept VALUES(1002, '财务部');
INSERT INTO dept VALUES(1003, '咨询部');

INSERT INTO emp VALUES(1,'张三',1001); #在添加这条记录时，要求部门表有1001部门
INSERT INTO emp VALUES(2,'李四',1001);
INSERT INTO emp VALUES(3,'王五',1002);

SELECT * FROM dept;
SELECT * FROM emp;

UPDATE dept SET dept_id = 1004 WHERE dept_id = 1002;

DELETE FROM dept WHERE dept_id = 1001;

-- 8. CHECK 约束
CREATE TABLE test10(
id INT,
last_name VARCHAR(15),
salary DECIMAL(10,2) CHECK(salary > 2000)
);

INSERT INTO test10
VALUES (1, 'Tom', 2500);
-- 添加失败：Check constraint 'test10_chk_1' is violated.
INSERT INTO test10
VALUES (2, 'Tom1', 1500);

SELECT * FROM test10;

-- 9. DEFAULT约束
-- 9.1 在CREATE TABLE添加约束
CREATE TABLE test11(
id INT,
last_name VARCHAR(15),
salary DECIMAL(10,2) DEFAULT 2000
);

DESC test11;

INSERT INTO test11(id, last_name, salary)
VALUES(1, 'Tom', 3000);

INSERT INTO test11(id, last_name)
VALUES(1, 'Tom');

SELECT * FROM test11;

-- 9.2 在 ALTER TABLE添加约束
CREATE TABLE test12(
id INT,
last_name VARCHAR(15),
salary DECIMAL(10,2)
);

ALTER TABLE test12
MODIFY salary DECIMAL(8,2) DEFAULT 2500;

DESC test12;

-- 9.3 删除约束
ALTER TABLE test12
MODIFY salary DECIMAL(8,2);
