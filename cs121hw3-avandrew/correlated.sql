-- [Problem a]

-- This query computes the number of loans for each of the customers.
-- It returns a table of customer name and their number of loans. 

SELECT customer_name,
               COUNT(loan_number) AS num_loans
FROM customer NATURAL LEFT JOIN borrower 
GROUP BY customer_name
ORDER BY num_loans DESC;


-- [Problem b]

-- This query computes which branches have less assets than the 
-- total amount of loans that they've given out.

SELECT branch_name
FROM branch NATURAL JOIN (
            SELECT l.branch_name, SUM(amount) AS total_amount
            FROM loan l
            GROUP BY l.branch_name) AS borrowed_amounts
WHERE assets < total_amount;


-- [Problem c]

SELECT branch_name, 
               (SELECT COUNT(*)
               FROM account
               WHERE account.branch_name = branch.branch_name) AS num_accounts,
               (SELECT COUNT(*) 
               FROM loan
               WHERE loan.branch_name = branch.branch_name) AS num_loans
FROM branch
ORDER BY branch_name;

-- [Problem d]

SELECT branch_name,
               COUNT(DISTINCT account_number) AS num_accounts,
               COUNT(DISTINCT loan_number) AS num_loans
FROM (branch NATURAL LEFT JOIN account) NATURAL LEFT JOIN loan
GROUP BY branch_name
ORDER BY branch_name;
                                      
                        

