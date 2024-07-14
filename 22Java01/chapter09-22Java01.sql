-- **********************************第九章 管理MySQL数据库**************************************

CREATE DATABASE IF NOT EXISTS mydb;

USE mydb;

-- 创建账户表
CREATE TABLE Account (
	acc_id CHAR (3) PRIMARY KEY,
	acc_name VARCHAR (10),
	balance INT
);

-- 创建产品表
CREATE TABLE IF NOT EXISTS Products
(
Product_ID INT NOT NULL,
Product_Name VARCHAR(45) NOT NULL ,
Quantity_In_Hand INT NOT NULL,
Re_Order_Quantity INT NULL,
Re_Order_Level INT NULL,
Price INT NULL,
PRIMARY KEY(Product_ID)
)
ENGINE = InnoDB;

-- 创建客户表
CREATE TABLE IF NOT EXISTS Customers
(
Customer_ID INT NOT NULL,
FirstName VARCHAR(45) NOT NULL,
LastName VARCHAR(45) NOT NULL,
Address VARCHAR(50) NOT NULL,
City VARCHAR(20),
Postal_Code INT,
PRIMARY KEY(Customer_ID)
)
ENGINE = InnoDB;


-- 创建客户订单表
CREATE TABLE IF NOT EXISTS Customer_Order
(
Order_ID INT NOT NULL,
Product_ID INT NOT NULL,
Customer_ID INT NOT NULL,
Quantity_Ordered INT NOT NULL,
CONSTRAINT FK_PID FOREIGN KEY (Product_ID)
REFERENCES Products(Product_ID),
CONSTRAINT FK_CID FOREIGN KEY (Customer_ID)
REFERENCES Customers(Customer_ID)
)
ENGINE = InnoDB;

-- 插入数据
INSERT INTO Account VALUES
('001','纪晓岚',10),
('002','和珅',1000),
('003','乾隆',500);

INSERT INTO Products VALUES
(1, 'Hard Rug', 26, 30, 2, 1000),
(2, 'Red Rugs', 400, 130, 1, 1500),
(3, 'Woolen Carpet', 0, 300, 3, 2300);

INSERT INTO Customers VALUES
(100001, 'Linda', 'Parker', '25, Rock Street, Brooklyn', 'Middle Town', 7748),
(100002, 'Nancy', 'Baker', '211 Green Avenue', 'New Jersey', 8060),
(100003, 'Karen', 'Thompson', '630, Western Square', 'Los Angeles', 3400);

INSERT INTO Customer_Order VALUES
(1001, 1, 100003, 23);

SHOW TABLES;

SELECT * FROM account;
SELECT * FROM Products;
SELECT * FROM Customers;
SELECT * FROM Customer_Order;

-- ************************************（一）管理用户账户****************************************
-- 1、创建用户账户
-- (1) 用户账户根据用户名和主机定义，用户名不能超过16个字符，主机可以使用主机名或IP地址表示。
-- (2) 可以创建带有密码或不带密码的用户账户，但是建议创建带有密码的用户账户。
-- (3) 可以通过两种方式创建用户账户：
-- A：使用CREATE USER语句
-- B：使用INSERT语句
-- 建议使用第一种方式创建用户账户，因为操作简单，出错机率更小。

-- 查看用户账户的详细信息（主机，用户名，密码和为其分配的权限）
SELECT * FROM mysql.user;

-- 方式一： 使用CREATE USER 语句
CREATE USER 'john'@'localhost'
IDENTIFIED BY 'password_join';

-- 可以使用一条CREATE USER语句创建多个用户账户
-- 创建用户账户时可以不指定主机，即不限定登录的主机
CREATE USER 
'joe' IDENTIFIED BY 'password_joe',
'smith' IDENTIFIED BY 'password_smith';

-- 可以创建不带密码的用户账户，但是不建议创建此类用户账户
CREATE USER 'robinson'@'192.168.0.1';

-- 主机可以使用通配符(%_)
CREATE USER 'john'@'%';
CREATE USER 'john'@'192.168.1.%';

-- 方式二：使用INSERT语句
DESC mysql.user;

-- INSERT 语句直接修改授权表，
INSERT INTO mysql.user(host, user, Ssl_cipher, x509_issuer, x509_subject) VALUES ('%', 'mon', '', '', '');
-- 需要执行一下语句刷新授权表
FLUSH privileges;

-- 2、修改用户账户
-- A、重命名用户账户 
-- RENAME USER old_account TO new_account [, old_account TO new_account ..]  可以同时重命名多个用户账户
RENAME USER 'joe'@'%' TO 'joe_new'@'localhost';

-- 也可以使用UPDATE语句直接修改user表
UPDATE mysql.user SET host = '%' WHERE user = 'joe_new' AND host = 'localhost';
FLUSH PRIVILEGES;

-- B、更改密码
-- 方式一、使用SET PASSWORD [for account_name] = 'encrypted_password'  为用户账户设置新密码或更改其当前密码
SET PASSWORD FOR 'joe_new'@'%' = 'joe_new';

-- 修改当前用户账户的密码
SET PASSWORD = 'root';

-- 方式二、使用UPDATE语句（MySQL 8不使用此方式）
UPDATE mysql.user SET authentication_string = 'joe_new' WHERE user = 'joe_new' AND host = '%';

-- 3、删除用户账户
-- 方式一：使用DROP USER 语句，可以同时删除多个用户账户
DROP USER 'smith'@'%';

-- 方式二：使用DELETE语句
DELETE FROM mysql.user WHERE user = 'joe_new' AND host = '%';
FLUSH PRIVILEGES;

-- ************************************（二）管理用户权限****************************************
/*
GRANT和REVOKE可在几个层次上控制访问权限：
 整个服务器，使用GRANT ALL和REVOKE ALL；
 整个数据库，使用ON database.*；
 特定的表，使用ON database.table；
 特定的列；
 特定的存储过程。

权限										说明
ALL 										除GRANT OPTION外的所有权限
ALTER 									使用ALTER TABLE
ALTER ROUTINE 					使用ALTER PROCEDURE和DROP PROCEDURE
CREATE 									使用CREATE TABLE
CREATE ROUTINE 					使用CREATE PROCEDURE
CREATE TEMPORARY TABLES	使用CREATE TEMPORARY TABLE
CREATE USER 						使用CREATE USER、 DROP USER、 RENAME USER和REVOKE ALL PRIVILEGES
CREATE VIEW 						使用CREATE VIEW
DELETE 									使用DELETE
DROP 										使用DROP TABLE
EXECUTE 								使用CALL和存储过程
FILE 										使用SELECT INTO OUTFILE和LOAD DATA INFILE
GRANT OPTION 						使用GRANT和REVOKE
INDEX 									使用CREATE INDEX和DROP INDEX
INSERT 									使用INSERT
LOCK TABLES 						使用LOCK TABLES
PROCESS 								使用SHOW FULL PROCESSLIST
RELOAD 									使用FLUSH
REPLICATION CLIENT 			服务器位置的访问
REPLICATION SLAVE 			由复制从属使用
SELECT 									使用SELECT
SHOW DATABASES 					使用SHOW DATABASES
SHOW VIEW 							使用SHOW CREATE VIEW
SHUTDOWN 								使用mysqladmin shutdown（用来关闭MySQL）
SUPER 									使用CHANGE MASTER、 KILL、 LOGS、 PURGE、 MASTER和SET GLOBAL。还允许mysqladmin调试登录
UPDATE 									使用UPDATE
USAGE 									无访问权限
*/

-- 1. 授予权限GRANT
-- （1）向指定用户分配对指定数据库的所有表具有指定权限
GRANT SELECT ON mydb.* TO 'john'@'%';

-- (2) 向指定用户分配对所有数据库的所有表具有指定权限
GRANT ALL ON *.* TO 'john'@'%';

-- 2、查看授权信息
SELECT * FROM mysql.user;

SHOW GRANTS FOR 'john'@'%';

-- 3、撤销权限
REVOKE SELECT ON *.* FROM 'john'@'%';

-- ***********************************（三）管理数据库可用性*************************************
/*
MySQL的二进制日志（binary log）是一个二进制文件，主要用于记录修改数据或有可能引起数据变更的MySQL语句。
二进制日志（binary log）中记录了对MySQL数据库执行更改的所有操作，并且记录了语句发生时间、执行时长、操作数据等其它额外信息，
但是它不记录SELECT、SHOW等那些不修改数据的SQL语句。二进制日志（binary log）主要用于数据库恢复和主从复制，以及审计（audit）操作。
*/
-- 查看二进制日志状态
SHOW VARIABLES LIKE 'log_bin';

-- 查看当前服务器所有的二进制日志文件
SHOW BINARY LOGS;
-- 或下面这个命令
SHOW MASTER LOGS;

-- 查看当前二进制日志文件状态
SHOW MASTER STATUS;

/*
开启二进制日志方法:
查看系统变量log_bin，如果其值为OFF，表示没有开启二进制日志（binary log），如果需要开启二进制日志，
则必须在my.ini中[mysqld]下面添加log_bin [=filename] ，
filename参数指定二级制文件的文件名。 其中filename可以任意指定，但最好有一定规范。
如：在my.ini文件的[mysqld]下面增加log_bin=mysql_bin_log，重启MySQL后，就会发现log_bin变为了ON。
*/
-- 显示二进制日志（binary log）默认存放目录
SHOW VARIABLES LIKE 'datadir';

-- 使用命令flush logs切换二进制日志
-- 每次重启MySQL服务也会生成一个新的二进制日志文件，相当于二进制日志切换。
-- 切换二进制日志时，你会看到这些number会不断递增。
SHOW MASTER STATUS;
FLUSH LOGS;

SHOW TABLES;
DROP TABLE football_star;

-- 备份数据
-- 1、备份一个数据库
-- A、备份数据库中所有表
mysqldump -u root -p mydb > d:/mydb.sql

-- B、备份数据库中的指定表
mysqldump -u root -p mydb account products > d:/account_products.sql

-- 2、备份多个数据库
-- A、备份指定数据库
/*
带--databases选项的mysqldump命令包含指定数据库的定义。
不带此选项的命令不包含指定数据库的定义。
*/
mysqldump -u root -p --databases mydb > d:/mydb.sql

-- B、备份MySQL服务器中的所有数据库
mysqldeump -u root -p --all-databases > d:/all_databases.sql

-- 恢复数据
SHOW DATABASES;
DROP DATABASE mydb;

USE mydb;
SHOW TABLES;

-- A、以批处理模式使用mysql程序
-- mysql
mysql -u root -p < d:/mydb.sql

-- B、以交互模式使用mysql程序
-- source
-- 使用mysql -u root -p命令登录到命令行客户端后，执行source命令
source d:/mydb.sql









