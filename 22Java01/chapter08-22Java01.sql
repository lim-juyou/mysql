-- ************************第八章 导出和导入数据************************
CREATE DATABASE IF NOT EXISTS mydb;

USE mydb;

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

-- ********************************（一）导出数据***********************************

/*
SELECT INTO…OUTFILE语句把表数据导出到一个文本文件中，并用LOAD DATA INFILE语句恢复数据。
但是这种方法只能导出或导入数据的内容，不包括表的结构，如果表的结构文件损坏，则必须先恢复原来的表的结构。
也可以将查询结果保存在变量中。
SELECT [INTO OUTFILE 'file_name' export_options
				| INTO DUMPFILE 'file_name'
				| INTO var_name [, var_name]]
*/

SELECT * INTO @id, @name, @balance FROM account WHERE acc_id = '001';

SELECT @id, @name, @balance;

-- ************************A、将数据导出到输出文件****************************
/*
SELECT INTO OUTFILE 'target_file' [option];
option 参数可以是以下选项：
	FIELDS TERMINATED BY 'string' （字段分隔符， 默认为制表符’\t’ ）；
	FIELDS [OPTIONALLY] ENCLOSED BY 'char' （字段引用符，如果加 OPTIONALLY 选项则只用在 
			char、varchar 和 text 等字符型字段上。 默认不使用引用符）；
	FIELDS ESCAPED BY 'char' （转义字符， 默认为’\’ ）；
	LINES STARTING BY 'string' （每行前都加此字符串 ， 默认'' ）；
	LINES TERMINATED BY 'string' （ 行结束符， 默认为’ \n’ ）；
其中 char 表示此符号只能是单个字符， string 表示可以是字符串。
*/

-- 如果设置了安全文件路径，则输出文件只能导出到该目录下
-- 显示导出文件的安全文件路径，即在my.ini配置文件的secure_file_priv选项中设置的路径
SHOW VARIABLES LIKE 'secure%';

/*
-- 如果不想导出到安全文件路径下。
修改my.ini配置文件：首先备份一下该文件，以防改错后能够恢复
将secure-file-priv="C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\"修改成secure-file-priv=
即secure-file-priv为空，这样就可以将文件导出到自己指定的目录下了
修改了此文件，需要重启数据库服务器
*/

-- 将数据导出到指定目录下
SELECT * FROM account
INTO OUTFILE "d:/account.txt";

-- 导出指定的列
SELECT acc_id, acc_name FROM account
INTO OUTFILE "d:/account_2col.txt";

SELECT * FROM account
INTO OUTFILE "d:/acc.txt"
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES STARTING BY '$$' TERMINATED BY '*';

-- *****************************B、将数据导出到转储文件************************** 
-- SELECT INTO DUMPFILE 'target_file'：用于导出Word文档、图片、视频、音频等二进制文件
-- 一次只能导出一个记录

-- max_allowed_packet: 指mysql服务器端和客户端在一次传送数据包的过程中最大允许的数据包大小。
SHOW VARIABLES LIKE 'max%';

-- BINARY: 固定长度二进制
-- BLOB: 可变长度二进制
-- TINYBLOB: 0-255字节
-- BLOB: 0-65K
-- MEDIUMBLOB: 0-16M
-- LONGBLOB: 0-4G

CREATE TABLE IF NOT EXISTS football_star
(
id INT PRIMARY KEY,
name VARCHAR(50),
photo MEDIUMBLOB,
intro BLOB
);

-- 插入图片和word文档
INSERT INTO football_star VALUES(1, '梅西', LOAD_FILE('d:/1.jpg'), LOAD_FILE('d:/1.docx'));

SELECT * FROM football_star;

-- 将图片导出到转储文件
SELECT photo FROM football_star WHERE id = 1 INTO DUMPFILE 'd:/11.jpg';
-- 将word文档导出转储文件
SELECT intro FROM football_star WHERE id = 1 INTO DUMPFILE 'd:/11.docx';

-- ************************** （二）导入数据 ***************************
/*
LOAD DATA INFILE语句用于高速的从一个文本文件中读取行，并写入到一个表中。
LODA DATA INFILE是SELECT INTO OUTFILE的相对语句
*/

TRUNCATE account;

SELECT * FROM account;

-- 1. LOAD DATA INFILE 'file_name' INTO TABLE table_name
LOAD DATA INFILE 'd:/account.txt' INTO TABLE account;

-- REPLACE | IGNORE 关键字
/*
REPLACE和IGNORE关键字用于控制对唯一键记录的重复的处理
REPLACE: 新行将代替有相同的唯一键值的现有行
IGNORE: 跳过有唯一键的现有行的重复行的输入
如果没有指定任何一个关键字，当找到重复键值时，就会报错，并且文本文件的余下部分就会被忽略。
*/

LOAD DATA INFILE 'd:/account.txt' REPLACE INTO TABLE account;

-- IGNORE n LINES
-- 从文本文件导入数据时，可以指定从文件的开始处忽略的行数
LOAD DATA INFILE 'd:/account.txt' INTO TABLE account
IGNORE 1 LINES;

-- 从文本文件中导入数据到表的部分列
LOAD DATA INFILE "d:/account_2col.txt" INTO TABLE account(acc_id, acc_name);

-- 带分隔符导入
-- 导入列选项和导出时对应
LOAD DATA INFILE "d:/acc.txt" INTO TABLE account
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES STARTING BY '$$' TERMINATED BY '*';

-- 2、source命令

-- 3、mysql命令

-- 4、mysqlimport实用程序
-- 查看是否开启加载本地文件
SHOW GLOBAL VARIABLES LIKE 'local_infile';
-- 开启全局本地文件设置
SET GLOBAL local_infile=1;

-- 语法：
-- shell> mysqlimport [options] <database_name> <file_name> [<file_name>...]
-- database_name：指定需要导入数据的数据库的名称
-- file_name：导入数据的文本文件的名称，文件名应与将要导入数据的表名相同（扩展名不包含在内）
-- options:
-- --columns=columns_list：指定要导入数据的列
-- --delete：在从文本文件导入数据之前移除表中的现有记录
-- --fields-terminated-by：指定字段分隔符
-- --fields-enclosed-by：指定字段引用符
-- --fields-escaped-by：指定转义字符
-- --ignore-lines：指定忽略前n行
-- --local：指定读取本地文件

-- shell> mysqlimport -u root -p --local mydb d:/account.txt

SELECT * FROM account;





