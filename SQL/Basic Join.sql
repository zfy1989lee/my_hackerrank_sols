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








