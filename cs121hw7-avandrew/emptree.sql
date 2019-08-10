-- [Problem 1]

DROP FUNCTION IF EXISTS total_salaries_adjlist;


DELIMITER !

CREATE FUNCTION total_salaries_adjlist (boss_id INTEGER) 
    RETURNS INTEGER
BEGIN
    DECLARE first_salary INTEGER;
    DECLARE row_changes INTEGER;
    -- Temporary table to store tuples that are obtained "recursively"
    DROP TEMPORARY TABLE IF EXISTS emps;
    CREATE TEMPORARY TABLE emps (
        emp_id INTEGER,
        salary INTEGER
	);
    -- Find salary of the first person, and insert into temp table
    SELECT salary 
    FROM employee_adjlist AS adj
    WHERE adj.emp_id = boss_id INTO first_salary;
    INSERT INTO emps VALUES (boss_id, first_salary);
    -- Repeat looking for employees whose managers are in temp table,
    -- but they are not already. This will add one level of the hierarchy 
    -- at a time. Stop when no more rows have changed.
    REPEAT 
        INSERT INTO emps 
            SELECT emp_id, salary
            FROM employee_adjlist
            WHERE manager_id IN (SELECT emp_id FROM emps) AND 
                emp_id NOT IN (SELECT emp_id FROM emps);
	    SELECT ROW_COUNT() INTO row_changes;
		UNTIL row_changes = 0
	END REPEAT;
    -- Sum the salaries of people from the subtree.
    RETURN (SELECT SUM(salary) FROM emps);
END !

DELIMITER ;

-- [Problem 2]

DROP FUNCTION IF EXISTS total_salaries_nestset;


DELIMITER !

CREATE FUNCTION total_salaries_nestset (boss_id INTEGER) 
    RETURNS INTEGER
BEGIN
    DECLARE first_salary INTEGER;
    DECLARE manager_low INTEGER;
    DECLARE manager_high INTEGER;
    -- Temporary table to store employees in subtree
    DROP TEMPORARY TABLE IF EXISTS employees;
    CREATE TEMPORARY TABLE employees (
        emp_id INTEGER,
        salary INTEGER,
        low INTEGER,
        high INTEGER
	);
	-- Extract low and high values from manager.
    INSERT INTO employees 
    SELECT emp_id, salary, low, high
    FROM employee_nestset AS nest
    WHERE nest.emp_id = boss_id;
    
    SELECT low FROM employees INTO manager_low;
    SELECT high FROM employees INTO manager_high;

    -- Find all employees under the manager (within range)
	INSERT INTO employees 
		SELECT emp_id, salary, low, high
		FROM employee_nestset
		WHERE low  > manager_low AND 
			high < manager_high;
	-- Sum up the salaries of people in subtree
    RETURN (SELECT SUM(salary) FROM employees);
END !

DELIMITER ;

-- [Problem 3]

-- Find people who are not anyone else's manager. This left
-- join would make b.manager_id NULL in this case.
SELECT a.emp_id
FROM employee_adjlist AS a LEFT JOIN 
		    employee_adjlist AS b ON a.emp_id = b.manager_id
WHERE b.manager_id IS NULL
ORDER BY a.emp_id;

-- [Problem 4]

-- Find people who are not anyone else's manager. This left 
-- join would make b.low NULL in this case.
SELECT a.emp_id 
FROM employee_nestset AS a LEFT JOIN
		    employee_nestset AS b ON a.low < b.low AND a.high > b.high
WHERE b.low IS NULL
ORDER BY a.emp_id;

-- [Problem 5]

-- I will use the adjacency list representation, because this 
-- more explicitly defines level to level. Like we did in problem 1,
-- we can traverse this level by level very easily.

DROP FUNCTION IF EXISTS tree_depth;

DELIMITER !

CREATE FUNCTION tree_depth() RETURNS INTEGER
BEGIN
    DECLARE row_changes INTEGER;
    -- i will keep track of current depth. Initialize to 1.
    DECLARE i INTEGER;
    -- First, we find the id of the first person in the tree.
    DECLARE boss_id INTEGER;
    SELECT emp_id FROM employee_adjlist WHERE manager_id IS NULL
        INTO boss_id;
    SET i = 1;
    -- Create temp table to track depth of different employees.
    CREATE TEMPORARY TABLE emps_depth (
        emp_id INTEGER,
        depth INTEGER
	);
    -- Put first person into table.
    INSERT INTO emps_depth VALUES (boss_id, 1);
    -- Recursively add each level into the table. Then increment
    -- the depth. 
    REPEAT
        INSERT INTO emps_depth SELECT emp_id, i + 1
            FROM employee_adjlist WHERE manager_id IN (
                SELECT emp_id FROM emps_depth WHERE depth = i) AND
                emp_id NOT IN (SELECT emp_id FROM emps_depth);
		SET i = i + 1;
        SELECT ROW_COUNT() INTO row_changes;
		UNTIL row_changes = 0
	END REPEAT;
    -- Return the largest depth that was achieved through this process. 
    RETURN (SELECT MAX(depth) FROM emps_depth);
END !

DELIMITER ;

-- [Problem 6]

DROP FUNCTION IF EXISTS emp_reports;


DELIMITER !

CREATE FUNCTION emp_reports (emp_id INTEGER) RETURNS INTEGER

BEGIN
    DECLARE manager_low INTEGER;
    DECLARE manager_high INTEGER;
    DECLARE first_reports INTEGER;
    -- Temporary table to store employees in subtree
    DROP TEMPORARY TABLE IF EXISTS emp_low_high;
    CREATE TEMPORARY TABLE emp_low_high (
        emp_id INTEGER,
        low INTEGER,
        high INTEGER
	);
    	-- Extract low and high values from manager.
    SELECT low, high
    FROM employee_nestset AS nest
    WHERE nest.emp_id = emp_id INTO manager_low, manager_high;
    -- Find all employees under the manager (within range)
	INSERT INTO emp_low_high 
		SELECT emp_id, low, high
		FROM employee_nestset
		WHERE low  > manager_low AND 
			high < manager_high;
	-- Find employees under manager that are not under other 
    -- children of the manager. They will have NULL values for 
    -- e2.low.
	SELECT COUNT(e1.emp_id) 
    FROM emp_low_high AS e1 LEFT JOIN
                emp_low_high AS e2 ON e1.low > e2.low AND e1.high < e2.high
	WHERE e2.low IS NULL INTO first_reports;
    RETURN first_reports;
END !

DELIMITER ;

