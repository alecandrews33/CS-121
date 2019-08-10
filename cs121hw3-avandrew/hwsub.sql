-- [Problem 1a]

SELECT SUM(perfectscore) AS perfect_grade
FROM assignment;

-- [Problem 1b]

SELECT sec_name, COUNT(username) AS num_students
FROM section NATURAL JOIN student
GROUP BY sec_name;

-- [Problem 1c]

CREATE VIEW totalscores AS 
SELECT username, SUM(score) as total_score
FROM submission
WHERE graded = 1
GROUP BY username;


-- [Problem 1d]

CREATE VIEW passing AS
SELECT * 
FROM totalscores
WHERE total_score >= 40;

-- [Problem 1e]

CREATE VIEW failing AS
SELECT * 
FROM totalscores
WHERE total_score < 40;

-- [Problem 1f]

SELECT username 
FROM fileset NATURAL RIGHT JOIN (
		    SELECT *
            FROM submission
            WHERE asn_id IN (
						   SELECT asn_id
                           FROM assignment
                           WHERE shortname LIKE 'lab%')) AS lab_submissions
WHERE username IN (
              SELECT username 
              FROM passing)
GROUP BY username
HAVING COUNT(fset_id) < COUNT(sub_id);

/* 
'coleman'
'edwards'
'flores'
'gibson'
'harris'
'miller'
'murphy'
'ross'
'simmons'
'tucker'
'turner'
*/

-- [Problem 1g]

SELECT username 
FROM fileset NATURAL RIGHT JOIN (
		    SELECT *
            FROM submission
            WHERE asn_id IN (
						   SELECT asn_id
                           FROM assignment
                           WHERE shortname LIKE '%final%' OR 
										 shortname LIKE '%midterm%')) AS lab_submissions
WHERE username IN (
              SELECT username 
              FROM passing)
GROUP BY username
HAVING COUNT(fset_id) < COUNT(sub_id);

/*
collins
*/

-- [Problem 2a]

SELECT DISTINCT username
FROM assignment NATURAL JOIN submission NATURAL JOIN fileset
WHERE shortname LIKE '%midterm%' AND sub_date > due;


-- [Problem 2b]

SELECT EXTRACT (HOUR FROM sub_date) AS hour,  COUNT(sub_id) AS num_submits
FROM assignment NATURAL JOIN submission NATURAL JOIN fileset
WHERE shortname LIKE 'lab%'
GROUP BY hour;


-- [Problem 2c]

SELECT COUNT(sub_id)
FROM assignment NATURAL JOIN (
            SELECT *
            FROM submission NATURAL JOIN fileset) AS assignment_submissions
WHERE shortname LIKE '%final%' AND 
			  sub_date BETWEEN (due - INTERVAL 30 MINUTE) AND due;

-- [Problem 3a]

ALTER TABLE student
ADD email VARCHAR(200);

UPDATE student 
SET email = username || '@school.edu';

ALTER TABLE student
CHANGE COLUMN email email VARCHAR(200) NOT NULL;


-- [Problem 3b]

ALTER TABLE assignment
ADD submit_files BOOLEAN DEFAULT TRUE;

UPDATE assignment
SET submit_files = FALSE
WHERE shortname LIKE 'dq%';

-- [Problem 3c]

CREATE TABLE gradescheme (
	scheme_id INTEGER PRIMARY KEY,
    scheme_desc VARCHAR(100) NOT NULL);
    
INSERT INTO gradescheme VALUES
(0, 'Lab assignments with min-grading.'),
(1, 'Daily quiz.'),
(2, 'Midterm or final exam.');

ALTER TABLE assignment
CHANGE COLUMN gradescheme scheme_id INTEGER NOT NULL;

ALTER TABLE assignment
ADD FOREIGN KEY (scheme_id) 
REFERENCES gradescheme (scheme_id);

-- [Problem 4a]

-- Set the "end of statement" character to ! so that 
-- semicolons in the function body won't confuse MySQL. 
DELIMITER !
-- Given a date value, returns TRUE if it is a weekend, 
-- or FALSE if it is a weekday.
CREATE FUNCTION is_weekend(d DATE) RETURNS BOOLEAN 
BEGIN

    IF DAYOFWEEK(d) BETWEEN 2 AND 6 THEN
        RETURN FALSE;
	ELSE
        RETURN TRUE;
	END IF;
    
END !
-- Back to the standard SQL delimiter 
DELIMITER ;


-- [Problem 4b]

-- Set the "end of statement" character to ! so that 
-- semicolons in the function body won't confuse MySQL. 
DELIMITER !
-- Given a date value, returns name of holiday if it is a holiday
-- and NULL if that date is not a holiday. 
CREATE FUNCTION is_holiday(d DATE) RETURNS VARCHAR(20)
BEGIN

    DECLARE holiday VARCHAR(20) DEFAULT NULL;
    DECLARE month CHAR(2);
    DECLARE day_of_week CHAR(1);
    DECLARE day_of_month CHAR(2);
    SET month = MONTH(d);
    SET day_of_week = DAYOFWEEK(d);
    SET day_of_month = DAYOFMONTH(d);
    
    IF month = 1 AND day_of_month = 1 THEN 
        SET holiday = 'New Year\'s Day';
	ELSEIF month = 5 AND day_of_month BETWEEN 25 AND 31 AND
                  day_of_week = 2 THEN 
        SET holiday = 'Memorial Day';
	ELSEIF month = 7 AND day_of_month = 4 THEN
        SET holiday = 'Independence Day';
	ELSEIF month = 11 AND day_of_week = 5 AND 
                  day_of_month BETWEEN 22 AND 28 THEN
	    SET holiday = 'Thanksgiving';
	ELSEIF month = 9 AND day_of_week = 2 AND 
                  day_of_month BETWEEN 1 AND 7 THEN
	    SET holiday = 'Labor Day';
	END IF;
    
    RETURN holiday;
    
    
END !
-- Back to the standard SQL delimiter 
DELIMITER ;

-- [Problem 5a]

SELECT is_holiday(DATE(sub_date)) AS holiday, COUNT(sub_id) AS num_subs
FROM fileset 
GROUP BY holiday;

-- [Problem 5b]

SELECT (CASE 
			        WHEN is_weekend(DATE(sub_date))= TRUE THEN 'weekend'
                    ELSE 'weekday' 
			   END) AS day_type, 
			   COUNT(sub_id) AS num_subs
FROM fileset
GROUP BY day_type;
