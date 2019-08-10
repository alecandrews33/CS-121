-- [Problem 1]

-- Must get the minimum time interval before each given logtime
-- for the same user. If this value is 30 minutes
WITH time_before (ip_addr, logtime, min_interval) AS (
    SELECT w1.ip_addr, w1.logtime, 
        -- Get minimum interval (time since most recent access)
        MIN(UNIX_TIMESTAMP(w1.logtime) - UNIX_TIMESTAMP(w2.logtime))
            AS min_interval
		-- Left join in case it is the first access
    FROM weblog AS w1 LEFT JOIN weblog AS w2 ON
        w1.ip_addr = w2.ip_addr AND 
        w1.logtime > w2.logtime
	GROUP BY w1.ip_addr, w1.logtime)
SELECT COUNT(*) AS num_visits
FROM time_before
-- Check if min interval is greater than 30 minutes, or NULL (first access)
WHERE min_interval >= 1800 OR min_interval IS NULL;

-- [Problem 2]

-- Our join has conditions on ip_addr and logtime, so create indices
-- on both of these columns to allow for easier access to tuples with 
-- a specific ip_addr or logtime. 
CREATE INDEX idx_ip_addr_logtime ON weblog (ip_addr, logtime);

-- [Problem 3]

DROP FUNCTION IF EXISTS num_visits;
-- Set the "end of statement" character to ! so that semicolons in the -- function body won't confuse MySQL.
DELIMITER !
CREATE FUNCTION num_visits() RETURNS INTEGER
BEGIN
    DECLARE first_time TIMESTAMP;
    DECLARE second_time TIMESTAMP;
    DECLARE current_interval INT;
    DECLARE done INT DEFAULT 0;
    DECLARE new_visits INT DEFAULT 0;
    DECLARE current_ip VARCHAR(100);
    DECLARE new_ip VARCHAR(100);
    
    -- The grouping of this cursor will make it so that we loop
    -- through all accesses by a given user in a contiguous chunk.
    DECLARE cur CURSOR FOR
        SELECT ip_addr, logtime
        FROM weblog
        GROUP BY ip_addr, logtime;
	
    -- Declare continue handler for case when no rows are returned.
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000'
        SET done = 1;
    OPEN cur;    
    -- Grab first values from cursor, and check if they exist. If they exist,
    -- then we have out first visit. 
	FETCH cur INTO current_ip, first_time;
    IF NOT done THEN 
        SET new_visits = 1;
	END IF;
    WHILE NOT done DO
        FETCH cur INTO new_ip, second_time;
        IF NOT done THEN
             -- If these second values have the same ip_addr,
             -- then they are from the same user. We only have 
             -- a new visit if the time interval is greater than 
             -- 30 minutes. 
            IF new_ip = current_ip THEN
                SET current_interval = 
                    UNIX_TIMESTAMP(second_time) - UNIX_TIMESTAMP(first_time);
                
                IF current_interval >= 1800 THEN
                    SET new_visits = new_visits + 1;
				END IF;
			-- If different ip_addr, then we know we have a new visit. Also,
            -- we must set current_ip to the new_ip.
			ELSE 
                SET current_ip = new_ip, 
						new_visits = new_visits + 1;
            END IF;
            SET first_time = second_time;
		END IF;
	END WHILE;
    
    RETURN new_visits;
END !
DELIMITER ;

SELECT num_visits();

