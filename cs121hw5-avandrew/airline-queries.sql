-- [Problem 6a]

SELECT purchase_date, flight_date, last_name, first_name
FROM purchase NATURAL JOIN 
            ticket NATURAL JOIN 
            seat_ticket NATURAL JOIN
            consumer
WHERE consumer_ID = 54321
ORDER BY purchase_date DESC;

-- [Problem 6b]

SELECT type_code, SUM(sale_price) AS total_revenue
FROM flights NATURAL JOIN 
            seat_ticket NATURAL JOIN 
            ticket
WHERE flight_date BETWEEN (CURDATE() - INTERVAL 2 WEEK) AND (CURDATE())
GROUP BY type_code;

-- [Problem 6c]

SELECT first_name, last_name
FROM flights NATURAL JOIN
            seat_ticket NATURAL JOIN
            ticket NATURAL JOIN
            traveler NATURAL JOIN
            consumer
WHERE flight_type = 'I' AND (passport_number IS NULL OR citizen_of IS NULL OR
    emergency_contact IS NULL OR emergency_phone IS NULL);

