-- [Problem 3]

-- Find how many distinct types of games each person has played. 
WITH games_played (person_id, person_name, num_types) AS (
    SELECT person_id, person_name, COUNT(DISTINCT type_id) AS num_types
    FROM geezer NATURAL JOIN 
                game_score NATURAL JOIN 
                game NATURAL JOIN 
                game_type
    GROUP BY person_id, person_name
)
SELECT person_id, person_name
FROM games_played
-- See which people have played the total number of distinct types of games.
WHERE num_types IN (
    SELECT COUNT(*) AS max_types
    FROM game_type);

-- [Problem 4]

DROP VIEW IF EXISTS top_scores;

-- Find player with top score for each distinct game
CREATE VIEW top_scores AS
SELECT DISTINCT type_id, type_name, person_id, person_name, high_score
FROM geezer NATURAL JOIN 
            game_score NATURAL JOIN 
            game NATURAL JOIN
            game_type NATURAL JOIN (
	SELECT type_id, MAX(score) AS high_score
	FROM game_score NATURAL JOIN game 
	GROUP BY type_id) AS high_scores
WHERE score = high_score
ORDER BY type_id, person_id;

-- [Problem 5]

-- Take the total number of games played over the types of games in 
-- our two week interval to find average number of games played.
-- Then find games who had more plays than average in our 2 week interval.
SELECT type_id
FROM game NATURAL JOIN game_type
WHERE game_date BETWEEN ('2000-04-18' - INTERVAL 2 WEEK) AND '2000-04-18'
GROUP BY type_id
HAVING COUNT(DISTINCT game_id) > (
    SELECT (COUNT(DISTINCT game_id) / COUNT(DISTINCT type_id)) AS avg_plays
    FROM game NATURAL JOIN game_type
    WHERE game_date BETWEEN ('2000-04-18' - INTERVAL 2 WEEK) AND '2000-04-18') ;

-- [Problem 6]

-- Find all cribbage games that Ted Codd played in and delete them.

DROP TABLE IF EXISTS temp;

CREATE TEMPORARY TABLE temp AS
SELECT DISTINCT game_id
FROM game_score NATURAL JOIN game NATURAL JOIN game_type NATURAL JOIN geezer
WHERE type_name = 'cribbage'  AND person_name = 'Ted Codd';

DELETE FROM game_score WHERE game_id IN (
    SELECT *
    FROM temp);
    
DELETE FROM game WHERE game_id IN (
    SELECT *
    FROM temp);

DROP TABLE IF EXISTS temp;

-- [Problem 7]

-- Find cribbage players and add line to prescriptions. Note the case when
-- their prescription is NULL. Use same temporary table idea 
-- from problem 6. 

DROP TABLE IF EXISTS cribbage_players;

CREATE TEMPORARY TABLE cribbage_players AS (
    SELECT DISTINCT person_id
    FROM game_score NATURAL JOIN game NATURAL JOIN game_type
    WHERE type_name = 'cribbage');
    
UPDATE geezer
SET prescriptions = IF(prescriptions IS NOT NULL,  
									CONCAT(prescriptions, ' Extra pudding on Thursdays!'),
									'Extra pudding on Thursdays!')
WHERE person_id IN (
    SELECT *
    FROM cribbage_players);       
    
DROP TABLE IF EXISTS cribbage_players;

-- [Problem 8]

-- Find the top scores in each game_id and then find the number
-- of winners for each game_id. Then sum over the number of 
-- winners using our point allocation. We group our aggregation
-- by each player. 

WITH winning_scores (game_id, max_score) AS (
    SELECT game_id, MAX(score) AS max_score
    FROM game_score NATURAL JOIN game NATURAL JOIN game_type
    WHERE min_players > 1
    GROUP BY game_id),
		  winners (game_id, num_winners) AS (
	SELECT game_id, COUNT(*) AS num_winners
    FROM winning_scores NATURAL JOIN game_score
    WHERE score = max_score
    GROUP BY game_id)
SELECT person_id, person_name, SUM(CASE 
                  WHEN num_winners = 1 THEN 1 
                  ELSE 0.5
                  END) AS total_points
FROM winners NATURAL JOIN geezer NATURAL JOIN game_score 
            NATURAL JOIN winning_scores
WHERE score = max_score
GROUP BY person_id, person_name
ORDER BY total_points DESC;







