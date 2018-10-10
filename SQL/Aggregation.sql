--Revising Aggregations - The Count Function
--经过测试， from不能放在where后面
SELECT COUNT(*)
FROM CITY
WHERE POPULATION > 100000;


--Revising Aggregations - The Sum Function
SELECT SUM(POPULATION)
FROM CITY
WHERE DISTRICT = "California";


--Revising Aggregations - Averages
SELECT AVG(POPULATION)
FROM CITY
WHERE DISTRICT = "California";


--Average Population
-- 一般编程语言的取整这么几种方式，  1， round函数， 四舍五入，可以选保留多少位小数， 
-- 2 floor 向下取整 3 ceil向上取整  4 int，或者integer，强制类型转换成整数  
-- 如果函数不对 也可以按照以上关键字去搜索
SELECT FLOOR(AVG(POPULATION))
FROM CITY;


-- Japan Population
SELECT SUM(POPULATION)
FROM CITY
WHERE COUNTRYCODE = "JPN"

--Population Density Difference
SELECT MAX(POPULATION) - MIN(POPULATION)
FROM CITY


--The Blunder
--其实不用CONCAT也可以，我就是为了确保数字能转换成字符串
SELECT CEIL(AVG(SALARY)- AVG(REPLACE(CONCAT(SALARY), '0', '')))
FROM EMPLOYEES


--Top Earners
--注意数据库叫EMPLYEE没有S
-- 我又加了个MAX是只想保留一个数

SELECT MAX(SALARY * MONTHS), COUNT(*)
FROM EMPLOYEE
WHERE SALARY * MONTHS = (SELECT MAX(SALARY * MONTHS) FROM EMPLOYEE)

-- 网上有个做法
SELECT (SALARY * MONTHS) AS EARNINGS, COUNT(*)
FROM EMPLOYEE
GROUP BY EARNINGS
ORDER BY EARNINGS DESC
LIMIT 1;

--Weather Observation Station 2
SELECT ROUND(SUM(LAT_N), 2), ROUND(SUM(LONG_W), 2)
FROM STATION


--Weather Observation Station 13

SELECT ROUND(SUM(LAT_N), 4)
FROM STATION
WHERE (LAT_N > 38.7800) AND (LAT_N < 137.2345)

--Weather Observation Station 14
SELECT ROUND(MAX(LAT_N), 4)
FROM STATION
WHERE (LAT_N < 137.2345)


--Weather Observation Station 15
SELECT ROUND(LONG_W, 4)
FROM STATION
WHERE LAT_N = (
				SELECT MAX(LAT_N)
				FROM STATION
				WHERE (LAT_N < 137.2345)
			)

--Weather Observation Station 16
SELECT ROUND(MIN(LAT_N), 4)
FROM STATION
WHERE (LAT_N > 38.7780)

--Weather Observation Station 17
SELECT ROUND(LONG_W, 4)
FROM STATION
WHERE LAT_N = (
				SELECT MIN(LAT_N)
				FROM STATION
				WHERE (LAT_N > 38.7780)
			)


--Weather Observation Station 18
--距离就是 |a-c|+ |b-d| 其实因为是MAX-MIN，连ABS都给省了
SELECT ROUND(ABS(MAX(LAT_N)-MIN(LAT_N)) + ABS(MAX(LONG_W) - MIN(LONG_W)), 4)
FROM STATION



--Weather Observation Station 19
--距离就是 SQRT(|a-c|^2+ |b-d|^2)
SELECT ROUND(SQRT((MAX(LAT_N)-MIN(LAT_N)) * (MAX(LAT_N)-MIN(LAT_N)) + (MAX(LONG_W) - MIN(LONG_W)) * (MAX(LONG_W) - MIN(LONG_W))), 4)
FROM STATION

--或者用power函数
SELECT ROUND(SQRT(POWER(MAX(LAT_N)-MIN(LAT_N), 2) + POWER(MAX(LONG_W) - MIN(LONG_W), 2)), 4)
FROM STATION


--Weather Observation Station 20
--我也算醉了。。。SQL居然没有中位数函数
--自己手动写个算法，如果是奇数行，就取中间的的那行数据，否则取中间两行数的平均值

SELECT IF((SELECT MOD(COUNT(LAT_N),2) FROM STATION) = 0,
        (SELECT AVG(ROUND(S.LAT_N, 4)) Median
            FROM STATION S
            WHERE ((SELECT COUNT(LAT_N) FROM STATION WHERE S.LAT_N > LAT_N) + 1) =
                  (SELECT COUNT(LAT_N) FROM STATION WHERE S.LAT_N < LAT_N)
                OR
                  (SELECT COUNT(LAT_N) FROM STATION WHERE S.LAT_N > LAT_N) =
                  ((SELECT COUNT(LAT_N) FROM STATION WHERE S.LAT_N < LAT_N) + 1)
         ),
        (SELECT ROUND(S.LAT_N, 4) Median
            FROM STATION S
            WHERE (SELECT COUNT(LAT_N) FROM STATION WHERE S.LAT_N > LAT_N) = 
                  (SELECT COUNT(LAT_N) FROM STATION WHERE S.LAT_N < LAT_N)
         ));


--我还可以用一个更加naive的办法， 添加一个rowindex列，表示行名 （注意是0， 1,2,3.。。从0开始）
--我们的目的就是找到第count/2行 或者 第count/2行 以及（count+1)/2行 ，取决于一共是奇数行还是偶数行

SET @rowindex := -1;
SELECT ROUND(AVG(S.LAT_N), 4)
FROM (
	SELECT @rowindex := @rowindex + 1 as rowindex, LAT_N
	FROM STATION
	ORDER BY LAT_N
) as S
WHERE
	S.rowindex IN (FLOOR(@rowindex / 2), CEIL(@rowindex / 2))
