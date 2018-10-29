--Asian Population
SELECT SUM(CITY.POPULATION)
FROM CITY INNER JOIN COUNTRY ON COUNTRY.CODE = CITY.COUNTRYCODE
WHERE COUNTRY.CONTINENT = 'Asia'

--当然方法不止一种哦， 不用join也能做
SELECT SUM(COUNTRY.POPULATION)
FROM CITY, COUNTRY
WHERE COUNTRY.CONTINENT = 'Asia'
AND COUNTRY.CODE = CITY.COUNTRYCODE


--African Cities
SELECT CITY.NAME
FROM CITY, COUNTRY
WHERE COUNTRY.CONTINENT = 'Africa'
AND COUNTRY.CODE = CITY.COUNTRYCODE

--Average Population of Each Continent
SELECT COUNTRY.CONTINENT, FLOOR(AVG(CITY.POPULATION))
FROM CITY, COUNTRY
WHERE COUNTRY.CODE = CITY.COUNTRYCODE
GROUP BY COUNTRY.CONTINENT

--The Report
--第一遍写的有点乱
--因为没有用join的方法，所以select层面没法用Grade来判断
SELECT 
    IF(Students.MARKS < 70, NULL, Students.NAME),
    (SELECT Grades.GRADE FROM Grades WHERE Students.MARKS BETWEEN Grades.MIN_MARK AND Grades.MAX_MARK ) as Grade, 
    Students.MARKS
FROM Students
ORDER BY GRADE DESC, NAME ASC, STUDENTS.MARKS ASC

--首先IF可用case语句替换，但是其实没必要
--其次用INNER JOIN的方法做， 后面on的是个between条件
--再者inner join on 和where + 条件效果差不多， 以下两个方法也可以组合
SELECT (CASE g.grade>=8 WHEN TRUE THEN s.name ELSE null END), g.grade,s.marks 
FROM students s INNER JOIN grades g ON s.marks BETWEEN min_mark AND max_mark 
ORDER BY g.grade DESC,s.name,s.marks;

select if(grade > 7, name, null), grade, marks 
from students, grades 
where marks between min_mark and max_mark 
order by grade desc, name, marks

--Top competiors
--我写的第一个版本，有点笨
--注意此题有bug， 题目的数据库有些人的分数是超过满分的。。。hhh
SELECT new_table.hacker_id, name
FROM
(
    SELECT Submissions.hacker_id, COUNT(*) as cnt    
    FROM (
        Submissions
        LEFT JOIN
        Challenges ON Submissions.challenge_id = Challenges.challenge_id
        LEFT JOIN
        Difficulty ON Challenges.difficulty_level = Difficulty.difficulty_level
    ) 
    WHERE Submissions.score = Difficulty.score
    GROUP BY Submissions.hacker_id    
) new_table 
LEFT JOIN Hackers ON Hackers.hacker_id = new_table.hacker_id
WHERE cnt > 1
ORDER BY cnt DESC, new_table.hacker_id ASC
--换个写法看看, GROUP BY 可以用两列的
SELECT new_table.hacker_id, name
FROM
(
    SELECT Submissions.hacker_id, name, COUNT(*) as cnt    
    FROM (
        Submissions
        LEFT JOIN 
        Hackers ON Hackers.hacker_id = Submissions.hacker_id
        LEFT JOIN
        Challenges ON Submissions.challenge_id = Challenges.challenge_id
        LEFT JOIN
        Difficulty ON Challenges.difficulty_level = Difficulty.difficulty_level
    ) 
    WHERE Submissions.score = Difficulty.score
    GROUP BY Submissions.hacker_id, Hackers.name    
) new_table 
WHERE new_table.cnt > 1
ORDER BY cnt DESC, new_table.hacker_id ASC
--其实我们可以去掉一层SELECT， 注意用HAVING 而不是where count(*)
SELECT Submissions.hacker_id, name    
FROM (
    Submissions
    LEFT JOIN 
    Hackers ON Hackers.hacker_id = Submissions.hacker_id
    LEFT JOIN
    Challenges ON Submissions.challenge_id = Challenges.challenge_id
    LEFT JOIN
    Difficulty ON Challenges.difficulty_level = Difficulty.difficulty_level
) 
WHERE Submissions.score = Difficulty.score
GROUP BY Submissions.hacker_id, name    
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC, Submissions.hacker_id ASC


--Ollivander's Inventory
--难点在于group by了之后怎么返回相应的id
-- 只能求助于子查询
SELECT id, age, coins_needed, dt1.power
FROM
    (SELECT code, power, MIN(coins_needed) as gaga
    FROM Wands
    GROUP BY code, power) dt1 
    LEFT JOIN Wands 
        ON dt1.code = Wands.code AND dt1.power = Wands.power AND dt1.gaga = Wands.coins_needed
    LEFT JOIN Wands_Property 
        ON Wands.code = Wands_Property.code
    WHERE is_evil = 0
ORDER BY dt1.power DESC, age DESC


--Challenges
--count比较简单，加了两个条件， 如果有重复的count并且不是max count，就删除
--相当于count外面再套一个count
/*
此题框架本来应该很简单
SELECT Hackers.hacker_id, Hackers.name, COUNT(*) AS cnt
FROM Hackers
    JOIN Challenges ON Hackers.hacker_id = Challenges.hacker_id
GROUP BY Hackers.hacker_id, Hackers.name
ORDER BY cnt DESC, Hackers.hacker_id
先把这步做好
蛋疼的是中间添加了cnt最多或者cnt of cnt =1的filter条件
我们最终采用HAVING来对cnt的值进行filter， 注意count of count相当于套了两层select query， 容易出错    
*/
SELECT Hackers.hacker_id, Hackers.name, COUNT(*) AS cnt
FROM Hackers
    JOIN Challenges ON Hackers.hacker_id = Challenges.hacker_id

GROUP BY Hackers.hacker_id, Hackers.name

HAVING 
    cnt = (     SELECT COUNT(*)
                FROM Challenges
                GROUP BY hacker_id
                ORDER BY COUNT(*) DESC
                LIMIT 1)
    OR
    cnt in (           
            SELECT temp.aoao
            FROM (
                SELECT COUNT(*) AS aoao
                FROM Challenges
                GROUP BY hacker_id
            ) temp
            GROUP BY aoao
            HAVING COUNT(temp.aoao) = 1)

ORDER BY cnt DESC, Hackers.hacker_id



--Contest Leaderboard
--两张表的嵌套而已
/*
表1 应该是求总分的写法
SELECT Hackers.hacker_id, Hackers.name, SUM(score) as total_score
FROM (
    Hackers
    JOIN 
    Sumbmissions ON Hackers.hacker_id = score_dt.hacker_id
)
GROUP BY Hackers.hacker_id, Hackers.name
HAVING total_score > 0
ORDER BY total_score DESC, Hackers.hacker_id ASC
但是，一个选手会submit多次， 我们只保留最高分， 所以，用来加重总分的表，应该是已经筛选过最高分的表
也就是这样：
SELECT hacker_id, MAX(score) as max_score
FROM Submissions
GROUP BY hacker_id, challenge_id
然后用这个表作为子查询 替换上面的JOIN就OK了
*/
SELECT Hackers.hacker_id, Hackers.name, SUM(max_score) as total_score
FROM (
    Hackers
    JOIN 
    (SELECT hacker_id, MAX(score) as max_score
    FROM Submissions
    GROUP BY hacker_id, challenge_id) score_dt 
    ON Hackers.hacker_id = score_dt.hacker_id
)
GROUP BY Hackers.hacker_id, Hackers.name
HAVING total_score > 0
ORDER BY total_score DESC, Hackers.hacker_id ASC