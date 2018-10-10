--Type of Triangle
--方法和EXCEL的if函数一样，语句为IF(条件判断， 为真返回的值， 为假返回的值)， 注意控制逻辑的嵌套
SELECT 
	IF(A+B>C AND A+C>B AND B+C>A, 
		IF(A=B AND B=C, 
			'Equilateral', 
			IF(A=B OR B=C OR A=C, 
				'Isosceles', 
				'Scalene')), 
		'Not A Triangle') 
FROM TRIANGLES;

--Type of Triangle
--其实when后的逻辑不严密，但是因为case是依次判断的， 所以下面的写法是正确的
SELECT 
	CASE 
		WHEN A + B <= C OR A + C <= B OR B + C <= A THEN 'Not A Triangle'
	    WHEN A = B AND B = C THEN 'Equilateral'
	    WHEN A = B OR A = C OR B = C THEN 'Isosceles'
	    ELSE 'Scalene'
	END
FROM TRIANGLES;

--The PADS
--两个部分分别写就好了

SELECT CONCAT(NAME, "(", LEFT(OCCUPATION, 1), ")")
FROM OCCUPATIONS
ORDER BY NAME ASC;

SELECT
CONCAT("There are a total of ",  TB.OCCUPATION_COUNT, ' ', LOWER(TB.OCCUPATION), IF(TB.OCCUPATION_COUNT > 1, 's', ''), '.')
FROM (
	SELECT OCCUPATION, count(*) AS OCCUPATION_COUNT
	FROM OCCUPATIONS
	GROUP by OCCUPATION
	ORDER BY OCCUPATION_COUNT, OCCUPATION
	
) AS TB;

--第二部分可以简化为
SELECT CONCAT("There are a total of ", COUNT(OCCUPATION), ' ', LOWER(OCCUPATION), 's.')
FROM OCCUPATIONS
GROUP by OCCUPATION
ORDER BY COUNT(OCCUPATION), OCCUPATION


--Occupations
--这个题不是很正经，需要点小技巧才能完成
-- 先构造一个row列， 表示一个名字该在第几行
SET @dRow = 0, @pRow = 0, @sRow = 0, @aRow = 0;

SELECT MIN(DOCTOR), MIN(PROFESSOR), MIN(SINGER), MIN(ACTOR)
FROM (
    SELECT  CASE Occupation    
                WHEN 'Doctor'       THEN @dRow := @dRow + 1
                WHEN 'Professor'    THEN @pRow := @pRow + 1
                WHEN 'Singer'       THEN @sRow := @sRow + 1
                WHEN 'Actor'        THEN @aRow := @aRow + 1
            END AS ROW,
            IF (OCCUPATION = 'Doctor', Name, NULL) AS DOCTOR,
            IF (OCCUPATION = 'Professor', Name, NULL) AS PROFESSOR,
            IF (OCCUPATION = 'Singer', Name, NULL) AS SINGER,
            IF (OCCUPATION = 'Actor', Name, NULL) AS ACTOR
    FROM    OCCUPATIONS
    ORDER BY NAME
) AS AOAO
GROUP BY ROW;


/*
内部的table AOAO形式如下， NULL 不参与对比， 用MAX 还是MIN无所谓
row, Doctor, Professor, Singer, Actor
1 Aamina NULL NULL NULL 
1 NULL Ashley NULL NULL 
2 NULL Belvet NULL NULL 
3 NULL Britney NULL NULL 
1 NULL NULL Christeen NULL 
1 NULL NULL NULL Eve 
2 NULL NULL Jane NULL 
2 NULL NULL NULL Jennifer 
3 NULL NULL Jenny NULL 
2 Julia NULL NULL NULL 
3 NULL NULL NULL Ketty 
4 NULL NULL Kristeen NULL 
4 NULL Maria NULL NULL 
5 NULL Meera NULL NULL 
6 NULL Naomi NULL NULL 
3 Priya NULL NULL NULL 
7 NULL Priyanka NULL NULL 
4 NULL NULL NULL Samantha 
*/


--New Companies
--最基本的做法，把对几个表的单独查询给join起来 （遇到了坑好久都没通过，一定注意要加distinct 关键字！！！）
SELECT A.company_code, A.founder, B.CNT, C.CNT, D.CNT, E.CNT
FROM
	(
			(SELECT company_code, founder
			FROM COMPANY) AS A
		INNER JOIN
			(SELECT company_code, COUNT(DISTINCT lead_manager_code) AS CNT
			FROM LEAD_MANAGER
			GROUP BY company_code) AS B
		ON A.company_code = B.company_code

		INNER JOIN
			(SELECT company_code, COUNT(DISTINCT senior_manager_code) AS CNT
			FROM SENIOR_MANAGER
			GROUP BY company_code) AS C
		ON A.company_code = C.company_code

		INNER JOIN		
			(SELECT company_code, COUNT(DISTINCT manager_code) AS CNT
	        FROM MANAGER
	        GROUP BY company_code) AS D
		ON A.company_code = D.company_code
		INNER JOIN		
			(SELECT company_code, COUNT(DISTINCT employee_code) AS CNT
	        FROM EMPLOYEE
	        GROUP BY company_code) AS E
		ON A.company_code = E.company_code
)
ORDER BY A.company_code



-- 其实不需要join，只用where就可以拼接 （full join）， 然后形成一个包含全部员工的大表
-- 如果有manager下面没有下属employee的情况，应该会被自动补充为NULL，SQL在count的时候，默认不统计NULL值

select c.company_code, c.founder, count(distinct lm.lead_manager_code), 
count(distinct sm.senior_manager_code), count(distinct m.manager_code), 
count(distinct e.employee_code)

from Company c, Lead_Manager lm, Senior_Manager sm, Manager m, Employee e
where c.company_code = lm.company_code
	and lm.lead_manager_code = sm.lead_manager_code
	and sm.senior_manager_code = m.senior_manager_code
	and m.manager_code = e.manager_code
group by c.company_code, c.founder
order by c.company_code



--以下做法能通过， 但是这个是个错误的做法， 连样例数据都通不过，因为他假设Employee这个表有全部的数据，然而有的manager可能不带employee呀
-- 就不会出现在employee表内
select  
        C.company_code ,
        C.founder,
        count(distinct lead_manager_Code),
        count(distinct senior_manager_Code),
        count(distinct Manager_Code),
        count(distinct Employee_Code)
        
    from Company C
        join Employee E on E.company_Code = C.company_Code

    group by C.company_code , C.founder
    
    order by C.company_code asc

--Binary Tree Nodes
/*
题目的二叉树看起来很唬人，然而， 逻辑其实是这样的
如果P是null， 那么N对应的是root
如果N没有作为parent出现过，也就是没在P出现过，那么N就是leaf
否则N是Inner
N的某个值是否出现在P列， 就要用到any函数
= any()的用法和 IN 啦， exist 差不多
*/


SELECT N, IF(P IS NULL, "Root", IF(N = ANY(SELECT DISTINCT P FROM BST), "Inner", "Leaf" ))
FROM BST
ORDER BY N

/*
这是discussion的一个解答， 可能有点难懂
主要理解(SELECT COUNT(*) FROM BST WHERE P=B.N) 这句话可以
SELECT COUNT(*) FROM BST WHERE P=N会返回0， 这句话相当于是查询BST这个
table P N两列一一对应，相等的行数有多少

然而 我换个写法也许你更好理解
SELECT (SELECT COUNT(*) FROM BST AS A WHERE B.N = A.P)
FROM BST AS B
ORDER BY N;
注意是B.N = A.P， 所以是B的N在A的P列里出现了多少次
*/
SELECT N, IF(P IS NULL,'Root',
	IF((SELECT COUNT(*) FROM BST WHERE B.N = P)>0,'Inner','Leaf')) 
FROM BST AS B 
ORDER BY N;
