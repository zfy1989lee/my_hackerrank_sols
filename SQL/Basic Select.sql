/*
All passed under MySQL
 */
-- Problem 1
SELECT *
FROM CITY
WHERE POPULATION > 100000 AND COUNTRYCODE REGEXP 'USA';

-- Problem 2
SELECT NAME
FROM CITY
WHERE POPULATION > 120000 AND COUNTRYCODE REGEXP 'USA';

-- Problem 3
SELECT *
FROM CITY;

-- Problem 4
SELECT *
FROM CITY
WHERE ID = 1661;

-- Problem 5
SELECT *
FROM CITY
WHERE COUNTRYCODE REGEXP "JPN";

-- Problem 5
SELECT *
FROM CITY
WHERE COUNTRYCODE REGEXP "JPN";

-- Problem 6
SELECT NAME
FROM CITY
WHERE COUNTRYCODE REGEXP "JPN";

-- Problem 7
SELECT DISTINCT CITY, STATE
FROM STATION;

-- Problem Weather Observation Station 3
SELECT DISTINCT CITY
FROM STATION
WHERE ID % 2 = 0;

-- Problem Weather Observation Station 4
SELECT  COUNT(CITY) - COUNT(DISTINCT CITY)
FROM STATION;


/*
正则表达式小基础：
^表示开头
$表示结尾
.*表示匹配任意字符串
^还有exclude的意思，但是要放在[]里面
*/


-- Problem Weather Observation Station 5
-- 无论如何，字符串长度函数不是len就是length或者nchar，遇到新的数据库系统就可以搜关键词了
(SELECT CITY, LENGTH(CITY)
FROM STATION
ORDER BY LENGTH(CITY), CITY LIMIT 1)
UNION
(SELECT CITY, LENGTH(CITY)
FROM STATION
ORDER BY LENGTH(CITY) DESC, CITY LIMIT 1)

-- Problem Weather Observation Station 6
SELECT DISTINCT CITY
FROM STATION
WHERE CITY REGEXP "^[aeiouAEIOU]"

-- Problem Weather Observation Station 7
SELECT DISTINCT CITY
FROM STATION
WHERE CITY REGEXP "[aeiouAEIOU]$"



-- Problem Weather Observation Station 8
SELECT DISTINCT CITY
FROM STATION
WHERE CITY REGEXP "^[aeiouAEIOU]" AND CITY REGEXP "[aeiouAEIOU]$"


-- Problem Weather Observation Station 8
SELECT DISTINCT CITY
FROM STATION
WHERE CITY REGEXP "(^[aeiouAEIOU]).*([aeiouAEIOU]$)";


-- Problem Weather Observation Station 9
SELECT DISTINCT CITY
FROM STATION
WHERE CITY NOT REGEXP "^[aeiouAEIOU]";


-- Problem Weather Observation Station 9
SELECT DISTINCT CITY
FROM STATION
WHERE SUBSTR(CITY, 1, 1) NOT IN ('A', 'E', 'I', 'O', 'U', 'a', 'e', 'i', 'o', 'u');


-- Problem Weather Observation Station 9
SELECT DISTINCT CITY
FROM STATION
WHERE CITY REGEXP "^[^aeiouAEIOU]";


-- Problem Weather Observation Station 10
SELECT DISTINCT CITY
FROM STATION
WHERE CITY REGEXP "[^aeiouAEIOU]$";


-- Problem Weather Observation Station 11
SELECT DISTINCT CITY
FROM STATION
WHERE CITY NOT REGEXP "(^[aeiouAEIOU]).*([aeiouAEIOU]$)";

-- Problem Weather Observation Station 11
SELECT DISTINCT CITY
FROM STATION
WHERE CITY NOT REGEXP "(^[aeiouAEIOU])" OR NOT CITY REGEXP "([aeiouAEIOU]$)";

-- Problem Weather Observation Station 12
SELECT DISTINCT CITY
FROM STATION
WHERE CITY REGEXP "(^[^aeiouAEIOU]).*([^aeiouAEIOU]$)";

--  Problem Higher Than 75 Marks
SELECT NAME
FROM STUDENTS
WHERE MARKS > 75
ORDER BY RIGHT(NAME, 3), ID ASC;

--  Problem Employee Names
SELECT NAME
FROM Employee
ORDER BY NAME;

--Employee Salaries
SELECT NAME
FROM Employee
WHERE SALARY > 2000 AND MONTHS < 10
ORDER BY EMPLOYEE_ID ASC;
