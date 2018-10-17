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