-- [Problem 1.4a]

SELECT hostname
FROM shared NATURAL JOIN basic
GROUP BY hostname
HAVING COUNT(username) > max_sites;


-- [Problem 1.4b]

UPDATE account
SET price = price - 2
WHERE username IN (
    SELECT username
    FROM basic NATURAL JOIN uses
    GROUP BY username
    HAVING COUNT(*) >= 3);

