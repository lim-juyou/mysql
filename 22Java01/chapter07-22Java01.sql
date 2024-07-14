-- ************************************第七章 实现触发器和事务**************************************
CREATE DATABASE IF NOT EXISTS mydb;

USE mydb;

-- DROP TABLE Customer_Order;
-- DROP TABLE Products;
-- DROP TABLE Customers;

CREATE TABLE IF NOT EXISTS Products
(
Product_ID INT NOT NULL,
Product_Name VARCHAR(45) NOT NULL ,
Quantity_In_Hand INT NOT NULL,
Re_Order_Quantity INT NULL,
Re_Order_Level INT NULL,
Price INT NULL,
PRIMARY KEY(Product_ID)
);

CREATE TABLE IF NOT EXISTS Customers
(
Customer_ID INT NOT NULL,
FirstName VARCHAR(45) NOT NULL,
LastName VARCHAR(45) NOT NULL,
Address VARCHAR(50) NOT NULL,
City VARCHAR(20),
Postal_Code INT,
PRIMARY KEY(Customer_ID)
);

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
);

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

-- DELETE FROM Customer_Order;

SELECT * FROM Products;
SELECT * FROM Customers;
SELECT * FROM Customer_Order;

-- ************************** （一）实现触发器 *********************************
/*
(1) 按触发时机：前触发器(BEFORE)和后触发器(AFTER)
(2) 按操作类型：DELETE触发器、INSERT触发器、UPDATE触发器
*/

-- 1. 创建BEFORE触发器
-- A. 创建BEFORE INSERT触发器
-- BEFORE INSERT触发器在向该触发器关联的表中添加行之前激活。
-- 创建触发器，确保添加到Products表中的产品价格为正数，否则抛出异常并显示相应的错误信息。

DELIMITER //

CREATE TRIGGER product_add BEFORE INSERT ON Products
FOR EACH ROW
BEGIN
	IF NEW.price < 0 THEN
		SIGNAL SQLSTATE '45000'
		SET message_text = '价格小于0';
	END IF;
END //

DELIMITER ;

INSERT INTO Products VALUES(4, 'Room Decor', 35, 100, 6, -50);

SELECT * FROM Products;

-- B、创建BEFORE UPDATE 触发器
-- BEFORE UPDATE 触发器在更新与该触发器关联的表中的每一条记录之前执行。
-- 创建触发器，确保产品的订购数量小于库存的对应数量，否则抛出异常并显示相应的错误信息。

DELIMITER //

CREATE TRIGGER check_order_quantity BEFORE UPDATE ON customer_order
FOR EACH ROW
BEGIN
	DECLARE quantity INT;
	
	SELECT quantity_in_hand INTO quantity FROM products
	WHERE product_id = NEW.product_id;
	
	IF NEW.quantity_ordered > quantity THEN
		SIGNAL SQLSTATE '45000'
		SET message_text = '库存数量不足';
	END IF;
END //

DELIMITER ;

UPDATE customer_order SET quantity_ordered = 20 WHERE order_id = 1001;

-- C、创建BEFORE DELETE触发器
-- BEFORE DELETE触发器在删除与该触发器关联的表中的每一条记录之前执行。
-- 创建触发器，在每次向Products表中插入记录时，向名为Product_Audit的表中插入记录
-- 来维护在Products表上执行操作的记录。

CREATE TABLE IF NOT EXISTS Product_Audit
(
product_id INT,
audit_action VARCHAR(11)
);

DELIMITER //

CREATE TRIGGER product_delete BEFORE DELETE ON products
FOR EACH ROW
BEGIN
	INSERT INTO product_audit VALUES(OLD.product_id, 'delete');
END //

DELIMITER ;

DELETE FROM products WHERE product_id = 2;

SELECT * FROM product_audit;
SELECT * FROM products;

-- 2. 创建后触发器
-- A、创建AFTER INSERT触发器
-- AFTER INSERT触发器在将每个记录插入与该触发器关联的表之后激活。
-- 创建触发器，在产品被订购后减少该产品的库存
SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM customer_order;

-- 触发语句
INSERT INTO customer_order VALUES(1002, 1, 100002, 23);


-- 创建前触发器 order_insert，在产品订购前确保产品的库存大于等于订单数量

-- B、创建AFTER UPDATE触发器
-- AFTER UPDATE触发器在更新与该触发器关联的表中的每一条记录之后激活。
-- 创建触发器，在product_audit表中维护对products表执行的更新操作。

CREATE TRIGGER product_update AFTER UPDATE ON products
FOR EACH ROW
	INSERT INTO product_audit VALUES(OLD.product_id, 'update');


-- 触发语句
UPDATE products SET quantity_in_hand = 20 WHERE product_id = 1;

SELECT * FROM product_audit;


-- C、创建AFTER DELETE触发器
-- AFTER DELETE触发器在删除与该触发器关联的表中的每一条记录之后执行。
-- 创建触发器，在删除客户所下订单时删除客户详细信息。

-- 3. 删除触发器
DROP TRIGGER IF EXISTS product_update;

/*
注意：
LOAD DATA语句用于将一个文件装入到一个数据表中，相当与一系列insert操作。
replace语句一般来说和insert语句很像，只是在表中有 primary key和unique索引时，
如果插入的数据和原来primary key和unique索引一致时，会先删除原来的数据，然后增加一条新数据；
也就是说，一条replace sql有时候等价于一条insert sql，有时候等价于一条delete sql加上一条insert sql。
即是：
    •   Insert型触发器：可能通过insert语句，load data语句，replace语句触发；
    •   Update型触发器：可能通过update语句触发；
    •   Delete型触发器：可能通过delete语句，replace语句触发；
*/

-- ***********************************(二)实现事务  Implementing Transactions********************************************
-- 事务就是一组原子性的sql，或者说一个独立的工作单元。
-- 事务就是说，要么mysql引擎会全部执行这一组sql语句，
-- 要么全部都不执行（比如其中一条语句失败的话）。
/*
事务的属性：ACID
Atomicity（原子性）：一个事务必须被视为一个不可分割的最小工作单元，整个事务中的所有操作要么全部提交成功，
										 要么全部失败回滚，对于一个事务来说，不可能只执行其中的一部分操作。
Consistency（一致性）：数据库总是从一个一致性状态转换到另一个一致状态。
Isolation（隔离性）：事务之间具有隔离性。事务的隔离性是通过锁、多版本并发控制(MVCC)等实现。
Durability（持久性）：一旦事务提交，则其所做的修改就会永久保存到数据库中。
											此时即使系统崩溃，修改的数据也不会丢失。（持久性的安全性与刷新日志级别也存在一定关系，
											不同的级别对应不同的数据安全级别。）
*/
CREATE TABLE Account (
	acc_id CHAR (3) PRIMARY KEY,
	acc_name VARCHAR(15),
	balance INT
);

-- 查看表使用的存储引擎
SHOW TABLE STATUS FROM niit WHERE name='Account';

-- DROP TABLE Account;

REPLACE INTO Account VALUES
('001', '纪晓岚', 10),
('002', '和珅', 1000),
('003', '乾隆', 500);

SELECT * FROM account;

-- 使用事务实现纪晓岚给和珅转账

UPDATE account SET balance = balance - 10 WHERE acc_id = '001';
UPDATE account SET balance = balance + 10 WHERE acc_id = '002';

-- A. 方式一：直接使用事务实现转账
-- 问题：在事务中需要手动手动使用ROLLBACK实现回滚，不能实现自动回滚
START TRANSACTION;	-- 开启事务

UPDATE account SET balance = balance - 10 WHERE acc_id = '001';
UPDATE account SET balance = balance + 10 WHERE acc_id = '002';

COMMIT ;	-- 提交事务

SELECT * FROM account;

START TRANSACTION;	-- 开启事务

UPDATE account SET balance = balance - 10 WHERE acc_id = '001';
UPDATE account SET balance = balance + 10 WHERE acc_id = '002';

ROLLBACK;

-- B. 方式二：使用触发器和事务实现转账

DELIMITER //

CREATE TRIGGER tri_before_account BEFORE UPDATE ON account
FOR EACH ROW
BEGIN
	IF NEW.balance < 0 THEN
		SIGNAL SQLSTATE '45000' SET message_text = '余额不足';
	END IF;
END //

DELIMITER ;

START TRANSACTION;	-- 开启事务

UPDATE account SET balance = balance + 10 WHERE acc_id = '002';
UPDATE account SET balance = balance - 10 WHERE acc_id = '001';

COMMIT ;	-- 提交事务

SELECT * FROM account;

-- 在存储过程中实现事务

DELIMITER //

CREATE PROCEDURE transfer()
BEGIN
	DECLARE t_error INTEGER DEFAULT 0;
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error = 1;

	START TRANSACTION;	-- 开启事务

	UPDATE account SET balance = balance + 10 WHERE acc_id = '002';
	UPDATE account SET balance = balance - 10 WHERE acc_id = '001';
	
	IF t_error = 1 THEN
		ROLLBACK;		-- 回滚事务
	ELSE
		COMMIT ;		-- 提交事务
	END IF;
	
	SELECT t_error;
END //

DELIMITER ;

SELECT * FROM account;

CALL transfer;

-- C. 方式三
DELIMITER //

CREATE PROCEDURE transfer_autocommit()
BEGIN
	DECLARE t_error INTEGER DEFAULT 0;
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error = 1;

	-- 禁用自动提交
	SET autocommit = 0;

	UPDATE account SET balance = balance + 10 WHERE acc_id = '002';
	
	-- 如果仅想回滚部分事务，可以使用SAVEPOINT语句设置保持点
	SAVEPOINT sav1;
	
	UPDATE account SET balance = balance - 10 WHERE acc_id = '001';
	
	IF t_error = 1 THEN
		 ROLLBACK;		-- 回滚事务
		-- 使用ROLLBACK TO SAVEPOINT savepoint_name 回滚到指定保持点
		-- ROLLBACK TO SAVEPOINT sav1;
	ELSE
		COMMIT ;		-- 提交事务
	END IF;
	
	-- 启用自动提交
	SET autocommit = 1;
	
	SELECT t_error;
END //

DELIMITER ;

SELECT * FROM account;

CALL transfer_autocommit;



