-- [Problem 1]

DROP FUNCTION IF EXISTS min_submit_interval;

DELIMITER !

CREATE FUNCTION min_submit_interval (
        submission_id INTEGER
)   RETURNS INTEGER
BEGIN
    DECLARE first_val TIMESTAMP;
    DECLARE second_val TIMESTAMP;
    DECLARE min_interval INTEGER DEFAULT NULL;
    DECLARE current_interval INT;
    DECLARE done INT DEFAULT 0;
    
    -- Declare cursor to iterate through returned rows. 
    DECLARE cur CURSOR FOR
        SELECT sub_date
        FROM fileset 
        WHERE sub_id = submission_id
        ORDER BY sub_date ASC;
	
    -- Declare continue handler for case when no rows are returned.
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000'
        SET done = 1;
    OPEN cur;    
	FETCH cur INTO first_val;
    WHILE NOT done DO
        FETCH cur INTO second_val;
        IF NOT done THEN
            SET current_interval = 
                UNIX_TIMESTAMP(second_val) - UNIX_TIMESTAMP(first_val);
                
            -- Check if the current interval is smaller than the minimum, or
            -- if the minimum doesn't exist. 
            IF min_interval IS NULL OR current_interval < min_interval THEN
                SET min_interval = current_interval;
			END IF;
            
            -- The next value will be fetched into second_val, so first_val
            -- will now be the current second_val.
            SET first_val = second_val;
		END IF;
	END WHILE;
    
    RETURN min_interval;
END !

DELIMITER ;

-- [Problem 2]

DROP FUNCTION IF EXISTS max_submit_interval;

DELIMITER !

CREATE FUNCTION max_submit_interval (
        submission_id INTEGER
)   RETURNS INTEGER
BEGIN
    DECLARE first_val TIMESTAMP;
    DECLARE second_val TIMESTAMP;
    DECLARE max_interval INTEGER DEFAULT NULL;
    DECLARE current_interval INT;
    DECLARE done INT DEFAULT 0;
    
    -- Declare cursor to iterate through returned rows. 
    DECLARE cur CURSOR FOR
        SELECT sub_date
        FROM fileset 
        WHERE sub_id = submission_id
        ORDER BY sub_date ASC;
        
	-- Declare continue handler for case when no rows are returned.
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000'
        SET done = 1;
	OPEN cur;
	FETCH cur INTO first_val;
    WHILE NOT done DO
        FETCH cur INTO second_val;
        IF NOT done THEN
            SET current_interval = 
                UNIX_TIMESTAMP(second_val) - UNIX_TIMESTAMP(first_val);
                
			-- Check if the current interval is larger than the maximum, or
            -- if the maximum doesn't exist. 
            IF max_interval IS NULL OR current_interval > max_interval THEN
                SET max_interval = current_interval;
			END IF;
            
            -- The next value will be fetched into second_val, so first_val
            -- will now be the current second_val.
            SET first_val = second_val;
		END IF;
	END WHILE;
    
    RETURN max_interval;
END !

DELIMITER ;

-- [Problem 3]

DROP FUNCTION IF EXISTS avg_submit_interval;

DELIMITER !

CREATE FUNCTION avg_submit_interval (
        submission_id INTEGER
)   RETURNS DOUBLE
BEGIN
    DECLARE avg_interval DOUBLE;
    
    -- The largest sub_date minus the smallest sub_date will 
    -- give the total interval length. The number of intervals is equal to the
    -- number of submissions minus 1. Divide interval length by number
    -- of intervals to get average interval length, 
    SELECT (UNIX_TIMESTAMP(MAX(sub_date)) - UNIX_TIMESTAMP(MIN(sub_date)))
						    / (COUNT(sub_date) - 1) INTO avg_interval
    FROM fileset 
    WHERE sub_id = submission_id
    -- There need to be at least 2 submissions to have an interval. 
    HAVING COUNT(sub_date) > 1;
    RETURN avg_interval;
END !

DELIMITER ;

-- [Problem 4]

-- This index will provide quicker access to rows with a specific sub_id. 

CREATE INDEX idx_sub_id ON fileset (sub_id);


