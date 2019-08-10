-- [Problem 1]

DROP TABLE IF EXISTS user_info;

CREATE TABLE user_info (
    username VARCHAR(20) PRIMARY KEY,
    salt CHAR(10) NOT NULL,
    -- 256 bits represents 64 hexadecimal digits
    password_hash CHAR(64) NOT NULL);


-- [Problem 2]

DROP PROCEDURE IF EXISTS sp_add_user;

DELIMITER !

CREATE PROCEDURE sp_add_user (
    IN new_username VARCHAR(20), 
    IN password VARCHAR(30)
)

BEGIN
	DECLARE new_salt CHAR(10);
    DECLARE new_password CHAR(64);
    -- Generate a new salt
    SELECT make_salt(10) INTO new_salt;
    -- Concatenate salt to password and then hash this
    SELECT SHA2(CONCAT(password, new_salt), 256) INTO new_password;
    INSERT INTO user_info (username, salt, password_hash)
    VALUES (new_username, new_salt, new_password);
END !

DELIMITER ;

-- [Problem 3]

DROP PROCEDURE IF EXISTS sp_change_password;

DELIMITER !

CREATE PROCEDURE sp_change_password (
    IN username VARCHAR(20), 
    IN password VARCHAR(30)
)

BEGIN
	DECLARE new_salt CHAR(10);
    DECLARE new_password CHAR(64);
    -- Still generate new salt for changing password
    SELECT make_salt(10) INTO new_salt;
    -- Concatenate salt and password and hash result
    SELECT SHA2(CONCAT(password, new_salt), 256) INTO new_password;
    -- Update the attributtes according to this username
    UPDATE user_info 
    SET salt = new_salt, password_hash = new_password
    WHERE user_info.username = username;
END !

DELIMITER ;

-- [Problem 4]

DROP FUNCTION IF EXISTS authenticate;

DELIMITER !

CREATE FUNCTION authenticate (username VARCHAR(20), password CHAR(64))
    RETURNS BOOLEAN
BEGIN
    DECLARE new_salt CHAR(10);
    DECLARE new_password CHAR(64);
    -- Check if username is in table
    IF username IN (SELECT username FROM user_info) THEN
    -- Get the stotred salt for this username 
        SELECT salt 
        FROM user_info AS u
        WHERE u.username = username INTO new_salt;
        SELECT SHA2(CONCAT(password, new_salt), 256) INTO new_password;
        -- If the hashed password matches what is stored, return true
        IF new_password = (SELECT password_hash 
                                     FROM user_info AS u 
                                     WHERE u.username = username) THEN RETURN TRUE;
		END IF;
    END IF;
    -- If either if statement fails, then return false
    RETURN FALSE;
END !

DELIMITER ;
