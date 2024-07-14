-- ********************** 第四章 使用联接和子查询来查询数据 ***********************************
USE mysqldb;

DESC employees;
DESC departments;
DESC locations;

-- 查询员工编号以及部门名称
SELECT employee_id, department_name
FROM employees JOIN departments
ON employees.department_id = departments.department_id;

-- 查询员工编号、部门名称和部门编号
-- 如果查询语句中出现了多个表中都存在的字段，则必须指明此字段所在的表
SELECT employee_id, department_name, employees.department_id
FROM employees JOIN departments
ON employees.department_id = departments.department_id;

-- 建议：从sql优化的角度，建议多表查询时，每个字段前都指明其所在的表。

-- 可以给表起别名，在SELECT和WHERE中使用表的别名
SELECT emp.employee_id, dept.department_name, emp.department_id
FROM employees emp JOIN departments dept
ON emp.department_id = dept.department_id;

/*
联接查询的分类：
角度1： 等值联接 VS 非等值联接

角度2：	自联结 VS 非自联结

角度3：内联接 VS 外连接
*/

-- 1 等值联接 VS 非等值联接
-- 非等值联接的例子：
-- 查询员工姓名、工资和工资等级
SELECT * FROM job_grades;

SELECT e.last_name, e.salary, j.grade_level
FROM employees e JOIN job_grades j
ON e.salary >= j.lowest_sal AND e.salary <= j.highest_sal;

-- 或者
SELECT e.last_name, e.salary, j.grade_level
FROM employees e JOIN job_grades j
ON e.salary BETWEEN j.lowest_sal AND j.highest_sal;

-- 2 自联结 VS 非自联结

-- 练习：查询员工id、员工姓名及其管理者的id和姓名
SELECT * FROM employees;

SELECT emp.employee_id, emp.last_name, mgr.employee_id, mgr.last_name
FROM employees emp JOIN employees mgr
ON emp.manager_id = mgr.employee_id;

-- 3 内联接 VS 外联接
-- 内连接：合并具有同一列的两个以上表的行，结果集中不包含一个表与另一个表不匹配

SELECT * FROM employees;

-- 查询员工编号以及部门名称
SELECT employee_id, department_name
FROM employees INNER JOIN departments
ON employees.department_id = departments.department_id;

-- 外连接：合并具有同一列的两个以上的表的行, 结果集中除了包含一个表与另一个表匹配的行之外，
--         还查询到了左表 或 右表中不匹配的行。

-- 外连接的分类：左外连接、右外连接、全外连接

-- 左外连接：两个表在连接过程中除了返回满足连接条件的行以外还返回左表中不满足条件的行，
-- 这种连接称为左外连接。
-- 右外连接：两个表在连接过程中除了返回满足连接条件的行以外还返回右表中不满足条件的行，
-- 这种连接称为右外连接。

-- 查询员工编号以及部门名称
-- 左外联接：
SELECT employee_id, department_name
FROM employees e LEFT OUTER JOIN departments d
ON e.department_id = d.department_id;

-- 右外联接：
SELECT employee_id, department_name
FROM employees e RIGHT OUTER JOIN departments d
ON e.department_id = d.department_id;

-- 全外联接
-- FULL OUTER JOIN，MySQL不支持FULL OUTER JOIN
-- UNION

SELECT employee_id, department_name
FROM employees e LEFT OUTER JOIN departments d
ON e.department_id = d.department_id
UNION
SELECT employee_id, department_name
FROM employees e RIGHT OUTER JOIN departments d
ON e.department_id = d.department_id;

-- 4. SQL99语法的新特性1：自然联接

-- NATURAL JOIN: 它会帮我们自动查询两张联接表中所有相同的字段，然后进行等值联接。
-- 查询员工编号以及部门名称
SELECT e.employee_id, d.department_name
FROM employees e INNER JOIN departments d
ON e.department_id = d.department_id;

SELECT e.employee_id, d.department_name
FROM employees e NATURAL INNER JOIN departments d;

-- 5. SQL99语法的新特性2: USING
-- USING: 指定数据表中的同名字段进行等值联接

-- 查询员工编号以及部门名称
SELECT e.employee_id, d.department_name
FROM employees e INNER JOIN departments d
USING(department_id);

-- 我们要控制连接表的数量 。多表连接就相当于嵌套 for 循环一样，非常消耗资源，会让 SQL 查询性能下
-- 降得很严重，因此不要连接不必要的表。在许多 DBMS 中，也都会有最大连接表的限制。

-- ***********************************(二)使用子查询查询数据******************************
-- 子查询：将一个SELECT的查询结果做为另一个SELECT的输入或条件

-- 1. 谁的工资比Abel的高？

-- 方式1： 
SELECT salary
FROM employees
WHERE last_name = 'Abel';

SELECT last_name, salary
FROM employees
WHERE salary > 11000;

-- 方式2：使用联接
SELECT e2.last_name, e2.salary
FROM employees e1 JOIN employees e2
ON e1.last_name = 'Abel' AND e2.salary > e1.salary;

-- 方式3：子查询
SELECT last_name, salary
FROM employees
WHERE salary > (
									SELECT salary
									FROM employees
									WHERE last_name = 'Abel'
								);
								
-- 2. 称谓的规范：外查询（或主查询）、内查询（或子查询）
/*
- 子查询（内查询）在主查询之前一次执行完成。
- 子查询的结果被主查询（外查询）使用 。
- 注意事项
  - 子查询要包含在括号内
  - 将子查询放在比较条件的右侧
  - 单行操作符对应单行子查询，多行操作符对应多行子查询
*/

/*
3. 子查询的分类
角度1：从内查询返回的结果的条目数
	单行子查询  vs  多行子查询

角度2：内查询是否被执行多次
	相关子查询  vs  不相关子查询
	
 比如：相关子查询的需求：查询工资大于本部门平均工资的员工信息。
       不相关子查询的需求：查询工资大于本公司平均工资的员工信息。
*/

-- 子查询的编写技巧（或步骤）：① 从里往外写  ② 从外往里写

-- 4. 单行子查询
-- 4.1 单行操作符： = != > >= < <=

-- 返回job_id与141号员工相同，salary比143号员工多的员工姓名、job_id和工资

SELECT last_name, job_id, salary
FROM employees
WHERE job_id = (
								SELECT job_id
								FROM employees
								WHERE employee_id = 141
								) AND 
			salary > (
								SELECT salary
								FROM employees
								WHERE employee_id = 143
								);
-- 4.2 单行子查询的空值问题
-- 查询和员工Hass的job_id相同的员工的last_name和job_id
SELECT last_name, job_id
FROM employees
WHERE job_id = (
								SELECT job_id
								FROM employees
								WHERE last_name = 'Haas'
								);

-- 4.3 非法使用单行子查询
-- 错误： Subquery returns more than 1 row
SELECT employee_id, last_name
FROM employees
WHERE salary = (
								SELECT MIN(salary)
								FROM employees
								GROUP BY department_id
								);

-- 5. 多行子查询
-- 5.1 多行子查询的操作符： IN ANY ALL SOME(同ANY)
-- IN：等于列表中的任意一个值
-- ANY: 需要和单行比较操作符一起使用，和子查询返回的任意一个值进行比较
-- ALL: 需要和单行比较操作符一起使用，和子查询返回的所有值进行比较
-- SOME 实际上是ANY的别名，作用相同，一般使用ANY

-- 5.2 举例
-- IN:
SELECT employee_id, last_name
FROM employees
WHERE salary IN (
								SELECT MIN(salary)
								FROM employees
								GROUP BY department_id
								);
-- ANY / ALL:
-- 返回其他job_id中比job_id为'IT_PROG'任一工资低的员工的编号、姓名、job_id以及salary
SELECT employee_id, last_name, job_id, salary
FROM employees
WHERE job_id != 'IT_PROG' AND 
			salary < ANY (
								SELECT salary
								FROM employees
								WHERE job_id = 'IT_PROG'
								);

-- 或
SELECT employee_id, last_name, job_id, salary
FROM employees
WHERE job_id != 'IT_PROG' AND 
			salary < (
								SELECT MAX(salary)
								FROM employees
								WHERE job_id = 'IT_PROG'
								);

-- 返回其他job_id中比job_id为'IT_PROG'所有工资低的员工的编号、姓名、job_id以及salary
SELECT employee_id, last_name, job_id, salary
FROM employees
WHERE job_id != 'IT_PROG' AND 
			salary < ALL (
								SELECT salary
								FROM employees
								WHERE job_id = 'IT_PROG'
								);
-- 或
SELECT employee_id, last_name, job_id, salary
FROM employees
WHERE job_id != 'IT_PROG' AND 
			salary < (
								SELECT MIN(salary)
								FROM employees
								WHERE job_id = 'IT_PROG'
								);

-- 查询平均工资最低的部门id
-- 错误方式：MySQL中聚合函数是不能嵌套使用的
SELECT MIN(AVG(salary))
FROM employees
GROUP BY department_id;

-- 方式一：
SELECT department_id
FROM employees
GROUP BY department_id
HAVING AVG(salary) = (
											SELECT MIN(avg_sal)
											FROM (
														SELECT AVG(salary) avg_sal
														FROM employees
														GROUP BY department_id
												) t_dept_avg_sal
											);

-- 方式二：
SELECT department_id
FROM employees
GROUP BY department_id
HAVING AVG(salary) <= ALL (
												SELECT AVG(salary) avg_sal
												FROM employees
												GROUP BY department_id
											);
											
SELECT * FROM employees;

-- 5.3 多行子查询的空值问题
-- 错误方式：
SELECT last_name
FROM employees
WHERE employee_id NOT IN (
													SELECT manager_id
													FROM employees
													);

-- 正确方式：
SELECT last_name
FROM employees
WHERE employee_id NOT IN (
													SELECT manager_id
													FROM employees
													WHERE manager_id IS NOT NULL
													);
-- 结论：在SELECT中，除了GROUP BY 和 LIMIT之外，其他位置都可以声明子查询！
/*
SELECT ....,....,....(存在聚合函数)
FROM ... (LEFT / RIGHT)JOIN ....ON 多表的连接条件 
(LEFT / RIGHT)JOIN ... ON ....
WHERE 不包含聚合函数的过滤条件
GROUP BY ...,....
HAVING 包含聚合函数的过滤条件
ORDER BY ....,...(ASC / DESC )
LIMIT ...,....
*/







