-- [Problem 1a]

SELECT DISTINCT name 
FROM student JOIN takes USING(ID) JOIN course USING(course_id)
WHERE course.dept_name = 'Comp. Sci.';


-- [Problem 1b]

SELECT dept_name, 
               MAX(salary) AS max_salary 
FROM instructor
GROUP BY dept_name;


-- [Problem 1c]

SELECT MIN(max_salary) AS min_salary 
FROM (SELECT dept_name, MAX(salary) AS max_salary 
             FROM instructor
             GROUP BY dept_name) AS dept_salaries;

-- [Problem 1d]

WITH dept_salaries (dept_name, max_salary) AS (
          SELECT dept_name, MAX(salary) AS max_salary 
          FROM instructor
          GROUP BY dept_name) 
SELECT MIN(max_salary) AS min_salary 
FROM dept_salaries;

-- [Problem 2a]

INSERT INTO course 
VALUES ('CS-001', 'Weekly Seminar', 'Comp. Sci.', 3);


-- [Problem 2b]

INSERT INTO section (course_id, sec_id, semester, year) 
VALUES('CS-001', '1', 'Fall', 2009);

-- [Problem 2c]

INSERT INTO takes (ID, course_id, sec_id, semester, year)
SELECT ID, 'CS-001', '1', 'Fall', 2009 FROM student
WHERE dept_name = 'Comp. Sci.';


-- [Problem 2d]

DELETE FROM takes 
WHERE course_id = 'CS-001' AND sec_id = '1' 
              AND ID =  (SELECT ID FROM student WHERE name = 'Chavez');
    

-- [Problem 2e]

DELETE FROM course 
WHERE course_id =  'CS-001';

-- Since the foreign key of course_id in the section table is set to 
-- "ON DELETE CASCADE" (in make-university), those tuples in section 
-- that are offerings of that particular course will also be deleted. This 
-- is done to ensure referential integrity. 

-- [Problem 2f]

DELETE FROM takes 
WHERE course_id IN (
              SELECT course_id 
              FROM course 
              WHERE LOWER(title) LIKE '%database%');
        

-- [Problem 3a]

SELECT DISTINCT name 
FROM member JOIN borrowed USING(memb_no) JOIN book USING(isbn) 
WHERE publisher = 'McGraw-Hill';



-- [Problem 3b]

SELECT name 
FROM member JOIN borrowed USING(memb_no) JOIN book USING(isbn) 
WHERE publisher = 'McGraw-Hill'
GROUP BY member.name
HAVING COUNT(*) = (SELECT COUNT(*) FROM book WHERE publisher = 'McGraw-Hill');

-- [Problem 3c]

SELECT name, publisher 
FROM member JOIN borrowed USING(memb_no) JOIN book USING(isbn) 
GROUP BY member.name, publisher
HAVING COUNT(*) > 5;

-- [Problem 3d]
SELECT AVG(book_count) AS avg_books 
FROM (SELECT COUNT(isbn) AS book_count 
            FROM member NATURAL LEFT JOIN borrowed
            GROUP BY name) AS book_counts;

-- [Problem 3e]

WITH book_counts (book_count) AS (
          SELECT COUNT(isbn) AS book_count 
          FROM member NATURAL LEFT JOIN borrowed
          GROUP BY name) 
SELECT AVG(book_count) AS avg_books 
FROM book_counts;



