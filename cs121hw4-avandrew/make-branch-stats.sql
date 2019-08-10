-- [Problem 1]

-- This index gives quicker access to accounts with a specific branch_name.

CREATE INDEX idx_branch_name ON account (branch_name);

-- [Problem 2]

DROP TABLE IF EXISTS mv_branch_account_stats;

CREATE TABLE mv_branch_account_stats (
    -- The name of the branch whose accounts are being examined.
    -- Primary key so that there aren't duplicate branches.
    branch_name VARCHAR(15) PRIMARY KEY,
    -- Number of accounts at branch_name.
    num_accounts INTEGER NOT NULL,
    -- The total deposits (sum of balances) at branch_name.
    total_deposits NUMERIC(12, 2) NOT NULL,
    -- The minimum balance at branch_name.
    min_balance NUMERIC(12, 2) NOT NULL,
    -- The maximum balance at branch_name.
    max_balance NUMERIC(12, 2) NOT NULL
);

-- [Problem 3]

-- Populate table with statistics from account.
INSERT INTO mv_branch_account_stats
    SELECT branch_name, 
                   COUNT(*) AS num_accounts,
                   SUM(balance) AS total_deposits,
                   MIN(balance) AS min_balance, 
                   MAX(balance) AS max_balance
	FROM account GROUP BY branch_name;

-- [Problem 4]

DROP VIEW IF EXISTS branch_account_stats;

-- Create view from mv_branch_account_stats.
CREATE VIEW branch_account_stats AS 
    SELECT branch_name,
				   num_accounts, 
				   total_deposits, 
                   -- Represent average balance as total_deposits/num_accounts.
                   total_deposits / num_accounts AS avg_balance, 
                   min_balance, 
                   max_balance
    FROM mv_branch_account_stats;

-- [Problem 5]

DROP PROCEDURE IF EXISTS sp_insert;

DELIMITER !

-- Stored procedure for an inserted row into account.
CREATE PROCEDURE sp_insert (
        IN branch_name VARCHAR(15),
        IN balance NUMERIC(12, 2)
)
BEGIN 
    INSERT INTO mv_branch_account_stats (branch_name, num_accounts, 
                                                                        total_deposits, min_balance,
                                                                        max_balance)
	    VALUES (branch_name, 1, balance, balance, balance)

    -- If this key (branch_name) was already inserted, update row
    -- with that particular key. 
	ON DUPLICATE KEY 
        UPDATE num_accounts = num_accounts + 1,
					    total_deposits = total_deposits + balance,
					    min_balance = LEAST(min_balance, balance),
						max_balance = GREATEST(max_balance, balance);
END !

DELIMITER ;

DROP TRIGGER IF EXISTS trg_insert;

DELIMITER !

-- Create trigger for inserts into account using stored procedure.
CREATE TRIGGER trg_insert AFTER INSERT ON account FOR EACH ROW
BEGIN
    CALL sp_insert (NEW.branch_name, NEW.balance);
END !

DELIMITER ;

-- [Problem 6]

DROP PROCEDURE IF EXISTS sp_delete;

DELIMITER !

-- Stored procedure for a deleted row in account.
CREATE PROCEDURE sp_delete (
        IN b_name VARCHAR(15),
        IN bal NUMERIC(12, 2)
)
BEGIN 
    DECLARE account_count INTEGER;
    DECLARE min_bal NUMERIC(12, 2);
    DECLARE max_bal NUMERIC(12, 2);
    -- Select the number of accounts, the minimum balance, and the 
    -- maximum balance. Keep in mind that this occurs after the delete,
    -- so these values will be accurate. 
    SELECT COUNT(*) , MIN(balance), MAX(balance) 
        INTO account_count, min_bal, max_bal
    FROM account WHERE branch_name = b_name;
    
    -- Check if there are any accounts remaining. If so, update the row
    -- for that particular branch name. Otherwise, delete the summary 
    -- for that branch name from the table. 
    IF account_count > 0 THEN
		UPDATE mv_branch_account_stats 
		SET num_accounts = num_accounts - 1, 
				total_deposits = total_deposits - bal,
				min_balance = min_bal,
				max_balance = max_bal
		WHERE branch_name = b_name;
	ELSE 
        DELETE FROM mv_branch_account_stats 
        WHERE branch_name = b_name;
	END IF;
            

END !

DELIMITER ;

DROP TRIGGER IF EXISTS trg_delete;

DELIMITER !

-- Create trigger for deletes on account.
CREATE TRIGGER trg_delete AFTER DELETE ON account FOR EACH ROW
BEGIN
    -- Must use OLD in order to get the values that were deleted. 
    CALL sp_delete (OLD.branch_name, OLD.balance);
END !

DELIMITER ;

-- [Problem 7]

DROP TRIGGER IF EXISTS trg_update;

DELIMITER !

-- Create trigger for updates on account. 
CREATE TRIGGER trg_update AFTER UPDATE ON account FOR EACH ROW
BEGIN
    DECLARE min_bal NUMERIC(12, 2);
    DECLARE max_bal NUMERIC(12, 2);
    
    -- Select the minimum and maximum balance to make sure these are
    -- accurate after the update. 
    SELECT MIN(balance), MAX(balance) INTO min_bal, max_bal
    FROM account WHERE branch_name = NEW.branch_name;
    
    -- Check if the branch_name was changed. If it wasn't, then update 
    -- all values except for num_accounts (since there was no insert or delete).
    -- If the name was changed, delete the summary of the old branch name 
    -- and insert a summary with the new branch name. 
    IF OLD.branch_name = NEW.branch_name THEN 
        UPDATE mv_branch_account_stats
        SET total_deposits = total_deposits + NEW.balance - OLD.balance,
                min_balance = min_bal,
                max_balance = max_bal
		WHERE branch_name = NEW.branch_name;
	ELSE
        CALL sp_delete(OLD.branch_name, OLD.balance);
        CALL sp_insert(NEW.branch_name, NEW.balance);
	END IF;
        
END !

DELIMITER ;

