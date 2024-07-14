-- ******************* 第三章 查询数据 **********************

-- 在命令行客户端登录mysql，使用source命令导入数据
-- mysql> source d:/mysqldb.sql

USE mysqldb;

SHOW TABLES;

-- ********************** 1. 检索数据 **************************
-- 1.1 检索特定属性
SELECT * FROM employees;

-- 查询指定字段
SELECT employee_id, last_name, salary
FROM employees;

-- 一般情况下，除非需要使用表中所有的字段数据，最好不要使用通配符‘*’。使用通配符虽然可以节
-- 省输入查询语句的时间，但是获取不需要的列数据通常会降低查询和所使用的应用程序的效率。通
-- 配符的优势是，当不知道所需要的列的名称时，可以通过它获取它们。
-- 在生产环境下，不推荐你直接使用 SELECT * 进行查询。

-- 1.2 列的别名
-- AS: alias（别名），可以省略
-- 列的别名可以使用一对""引起了，不要使用''
SELECT employee_id emp_id, last_name AS lname, department_id "部门id"
FROM employees;

-- 1.3 去除重复行
-- 查询员工表中一有哪些部门id
-- 没有去重
SELECT department_id
FROM employees;

-- 去重
SELECT DISTINCT department_id
FROM employees;

-- 1.4 空值参与运算
-- (1)空值：NULL
-- (2)NULL 不等同于0，'', 'NULL'
SELECT * FROM employees;

-- (3) 空值参与算术运算，结果一定为NULL
-- 查询员工的月工资和年工资
SELECT employee_id, salary "月工资", salary * (1 + commission_pct) * 12 "年工资", commission_pct
FROM employees;

-- 解决方案: 引入IFNULL
SELECT employee_id, salary "月工资", salary * (1 + IFNULL(commission_pct, 0)) * 12 "年工资", commission_pct
FROM employees;

-- 1.5 着重号``
-- 我们需要保证表中的字段、表名等没有和保留字、数据库系统或常用方法冲突。
-- 如果真的相同，请在SQL语句中使用一对``（着重号）引起来。
SELECT * FROM `order`;

-- 1.6 显示表结构
DESCRIBE employees;
DESC employees;

-- 1.7 过滤数据
-- 练习：查询90号部门的员工信息
SELECT * FROM employees WHERE department_id = 90;

-- 练习：查询last_name为'King'的员工信息
SELECT * FROM employees WHERE last_name = 'King';

SELECT * FROM employees WHERE last_name = 'king';

-- COLLATE(字符序)决定是否区分大小写
-- 查看当前数据库的字符序（了解）
SHOW VARIABLES LIKE 'collation%';

SELECT * FROM employees WHERE last_name = 'King'
COLLATE utf8mb4_0900_as_cs;

SELECT * FROM employees WHERE last_name = 'king'
COLLATE utf8mb4_0900_as_cs;

-- 使用BINARY函数
SELECT * FROM employees WHERE BINARY(last_name) = 'king';

-- 1.8 算术运算符：+ - * / div % mod
SELECT 100 / 50, 100 DIV 50;

-- 练习：查询员工id为偶数的员工信息
SELECT employee_id, last_name
FROM employees
WHERE employee_id mod 2 = 0;

-- 1.9 比较运算符
-- = <=>(安全等于) <> != < <= > >=

-- 字符串存在隐式转换，如果转换数值不成功，则看作0
SELECT 1 = 2, 1 != 2, 1 = '1', 1 = 'a', 0 = 'a';

-- 只要有NULL参与判断，结果就为NULL
SELECT 1 = NULL, NULL = NULL;

SELECT * FROM employees;

-- 查询commission_pct为NULL的员工信息
SELECT last_name, salary, commission_pct
FROM employees
WHERE commission_pct = NULL;

-- <=>: 安全等于，为NULL而生
-- 操作数不包含NULL时与=相同
SELECT 1 <=> 2, 1 <=> '1', 1 <=> 'a', 0 <=> 'a';

-- 操作数都为NULL时为1，一个操作数为NULL时为0
SELECT 1 <=> NULL, NULL <=> NULL;

-- 查询commission_pct为NULL的员工信息
SELECT last_name, salary, commission_pct
FROM employees
WHERE commission_pct <=> NULL;

-- 1.10 IS NULL, IS NOT NULL, ISNULL()
-- 查询commission_pct为NULL的员工信息
SELECT last_name, salary, commission_pct
FROM employees
WHERE commission_pct IS NULL;
-- 或者
SELECT last_name, salary, commission_pct
FROM employees
WHERE ISNULL(commission_pct);

-- 练习： 查询commission_pct不为NULL的员工信息

-- 1.11 逻辑运算符 AND(&&) OR(||) NOT(!)

-- 1.12 指定连续范围运算符 BETWEEN AND，包含左右两边的边界值
-- 查询工资在6000 到 8000 之间的员工信息
SELECT * FROM employees;

SELECT * FROM employees
WHERE salary >= 6000 AND salary <= 8000;
-- 或者
SELECT * FROM employees
WHERE salary BETWEEN 6000 AND 8000;

-- 查询工资不在6000 到 8000 之间的员工信息
SELECT * FROM employees
WHERE salary < 6000 OR salary > 8000;
-- 或者
-- NOT BETWEEN AND: 在范围之外，不包含边界值
SELECT * FROM employees
WHERE salary NOT BETWEEN 6000 AND 8000;

-- 1.13 有限列表运算符 IN
-- 查询部门为10，20，30部门的员工信息
SELECT last_name, salary, department_id
FROM employees
WHERE department_id = 10 OR department_id = 20 OR department_id = 30;
-- 或者
SELECT last_name, salary, department_id
FROM employees
WHERE department_id IN (10, 20, 30);

-- 查询部门不是10，20，30部门的员工信息
SELECT last_name, salary, department_id
FROM employees
WHERE department_id != 10 AND department_id != 20 AND department_id != 30;
-- 或
SELECT last_name, salary, department_id
FROM employees
WHERE department_id NOT IN (10, 20, 30);

-- 1.14 模式匹配运算符 LIKE , 即模糊查询
-- 通配符：
-- %: 表示任意个数的字符
-- _：表示任意单个字符

-- 查询员工名第二个字母是a的员工信息
SELECT * FROM employees
WHERE first_name LIKE '_a%';

-- 1.15 使用LIMIT子句实现分页 LIMIT [offset, ] row_count
-- 查询前5行员工信息
SELECT * FROM employees LIMIT 0, 5;

-- 或仅指定一个参数
-- LIMIT仅指定一个参数时，默认offset为0
SELECT * FROM employees LIMIT 5;

-- 查询第5-9行员工的信息
SELECT * FROM employees LIMIT 4, 5;

-- offset = (当前页码 - 1) * row_count
-- 每页显示10条数据，查询第1页数据
SELECT * FROM employees LIMIT 0, 10;

-- 每页显示10条数据，查询第2页数据
SELECT * FROM employees LIMIT 10, 10;

-- 每页显示10条数据，查询第3页数据
SELECT * FROM employees LIMIT 20, 10;

-- 练习：查询第32、33这两条数据

-- ********************* 2. 使用函数来自定义结果集 ************************
/*
内置函数分类：
字符串函数
日期函数
数学函数
信息函数
转换函数
聚合函数
*/
-- 2.1 字符串函数
-- 显示所有员工的全名
-- CONCAT
SELECT CONCAT(first_name, ' ', last_name) AS "emp_name" FROM employees;

-- UPPER(str), LOWER(str)

-- SUBSTR(), TRIM()

-- REGEXP 
/*
字符类：
[]: 表示范围内的任意单个字符，例：[abc]
[^]: 表示不在范围内的任意单个字符，例：[^abc]
[a-z],[A-Z],[0-9],[^a-z]

特殊符号：
.: 表示任意的单个字符
^: 字符串以某个字符开头
$: 字符串以某个字符结尾

量词：
*：0个或任意数目字符
+：1个或任意数目字符
*/
-- 查询所有名字以L开头的员工信息
SELECT * FROM employees WHERE first_name REGEXP '^L.*';
SELECT * FROM employees WHERE first_name REGEXP '^L[a-z]*';

-- 查询所有名字以L或M开头，以y结尾的员工信息
SELECT * FROM employees WHERE first_name REGEXP '^[LM].*y$';
SELECT * FROM employees WHERE first_name REGEXP '^[LM][a-z]*y$';

-- 2.2 日期函数
-- 查看当前系统日期
SELECT CURDATE();
-- 查看当前系统时间
SELECT CURTIME();

-- 计算截至到当前日期，自己出生了多少天
-- DATEDIFF
SELECT DATEDIFF('1989-10-15', CURDATE()) AS days;

-- YEAR(), MONTH(), DAY()

-- 将员工编号105的员工，将他的入职日期推迟一个月
-- ADDDATE
SELECT employee_id, hire_date, ADDDATE(hire_date, INTERVAL 1 MONTH)
FROM employees WHERE employee_id = 105;

-- 2.3 数学函数
-- 计算员工的日工资，保留一位小数
-- ROUND
SELECT employee_id, salary, ROUND(salary / 30, 1) AS rate
FROM employees;

-- FLOOR: 向下取整
-- CEILING: 向上取整

-- 2.4 信息函数
-- 返回当前登录用户的用户名和主机名
SELECT CURRENT_USER();
-- 返回当前使用的数据库名称
SELECT DATABASE();

-- 2.5 转换函数
-- LIKE, = 是否区分大小写？
SELECT * FROM employees WHERE last_name = 'Smith';
SELECT * FROM employees WHERE last_name = 'smith';
-- BINARY(): 比较数据时区分大小写
SELECT * FROM employees WHERE last_name = BINARY('Smith');
SELECT * FROM employees WHERE last_name = BINARY('smith');

-- CAST(), CONVERT(): 数据类型转换

-- 2.6 聚合函数
-- 聚合函数汇总一列或一组列，生成一个值，又称分组函数

-- AVG / SUM: 只适用于数值类型的字段（或变量）
-- MAX / MIN: 适用于数值类型、字符串类型、日期时间类型的字段（或变量）
-- 统计员工的总工资、平均工资、最高和最低工资
SELECT SUM(salary) AS "总工资",
AVG(salary) AS "平均工资",
MAX(salary) AS "最高工资",
MIN(salary) AS "最低工资"
FROM employees;

-- COUNT(*): 返回表中记录总数
-- COUNT(expr): 返回expr不为NULL的记录总数, 计算指定字段出现的个数时，是不计算NULL值的。
-- 统计员工表中员工的数量
SELECT COUNT(*), COUNT(last_name), COUNT(commission_pct)
FROM employees;

-- 查询公司中平均奖金率
-- 错误的
SELECT AVG(commission_pct), SUM(commission_pct) / COUNT(commission_pct)
FROM employees;

SELECT * FROM employees;

-- 正确的
SELECT AVG(IFNULL(commission_pct, 0)), SUM(commission_pct) / COUNT(IFNULL(commission_pct, 0))
FROM employees;

-- *********************** 3. 排序和分组数据 ***************************
-- 3.1 数据排序 ORDER BY
-- 根据员工工资降序显示员工信息
SELECT * FROM employees
ORDER BY salary DESC;

-- 根据员工工资升序显示员工信息
-- ORDER BY子句默认采用升序排序，所有ASC可以省略不写
SELECT * FROM employees
ORDER BY salary ASC;

-- 多重排序：先根据姓氏降序，在根据名字升序显示员工信息
SELECT * FROM employees
ORDER BY last_name DESC, first_name ASC;

-- 3.2 分组数据 GROUP BY
-- （1）根据单个字段分组
-- 显示不同job_id的员工的总工资和平均工资
SELECT job_id, SUM(salary) AS "总工资", AVG(salary) AS "平均工资"
FROM employees
GROUP BY job_id;

-- (2) 对分组结果进行过滤，进一步过滤掉不满足条件的行，使用HAVING
-- -- 显示不同job_id的员工的总工资和平均工资，去掉平均工资小于4000的记录
-- 错误的
SELECT job_id, SUM(salary) AS "总工资", AVG(salary) AS "平均工资"
FROM employees
WHERE AVG(salary) >= 4000
GROUP BY job_id;

-- 正确的
SELECT job_id, SUM(salary) AS "总工资", AVG(salary) AS "平均工资"
FROM employees
GROUP BY job_id
HAVING AVG(salary) >= 4000;

-- （3）根据多个字段进行分组
-- 按照职位和入职日期进行分组，然后计算员工的总工资和平均工资
SELECT job_id, hire_date, SUM(salary), AVG(salary)
FROM employees
GROUP BY job_id, hire_date;

-- 注意：分组之后，查询的字段必须为聚合函数和分组字段，查询其他字段无任何意义
-- 显示不同job_id的员工的总工资和平均工资
SELECT first_name, job_id, SUM(salary) AS "总工资", AVG(salary) AS "平均工资"
FROM employees
GROUP BY job_id;

-- 需要记住 SELECT 查询时的两个顺序：
-- 1. 关键字的书写顺序是不能颠倒的：
-- SELECT ... FROM ... WHERE ... GROUP BY ... HAVING ... ORDER BY ... LIMIT...
-- 2.SELECT 语句的执行顺序（在 MySQL 和 Oracle 中，SELECT 执行顺序基本相同）：
-- FROM -> WHERE -> GROUP BY -> HAVING -> SELECT 的字段 -> DISTINCT -> ORDER BY -> LIMIT






