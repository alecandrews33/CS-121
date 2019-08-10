-- [Problem 1.1]
SELECT * FROM acl;
DROP TABLE IF EXISTS acl;

CREATE TABLE acl (
    -- This will be the full path of a given resource
    path VARCHAR(1000) NOT NULL,
    -- The user that the permission is specified for
    user VARCHAR(20) NOT NULL,
    -- What the permission is
    permission VARCHAR(20) NOT NULL,
    -- Whether the permssion is granted or denied.
    access CHAR(1) NOT NULL,
    PRIMARY KEY (path, user, permission),
    -- access can only be G or D for grant or deny.
    CHECK(access IN ('G', 'D'))
);

-- [Problem 1.2]

DROP PROCEDURE IF EXISTS add_perm;

DELIMITER !

CREATE PROCEDURE add_perm (
    IN res_path VARCHAR(1000), 
    IN user VARCHAR(20),
    IN perm VARCHAR(20), 
    IN grant_perm BOOLEAN)
    
BEGIN
    DECLARE access_perm CHAR(1);
    -- Set access_perm to the corresponding CHAR
    IF grant_perm THEN 
        SET access_perm = 'G';
	ELSE 
        SET access_perm = 'D';
	END IF;
    -- Insert the new tuple
    INSERT INTO acl  (path, user, permission, access) 
    VALUES (res_path, user, perm, access_perm);
END !

DELIMITER ;

-- [Problem 1.3]

DROP PROCEDURE IF EXISTS del_perm;

DELIMITER !

CREATE PROCEDURE del_perm (
    IN res_path VARCHAR(1000), 
    IN user VARCHAR(20),
    IN perm VARCHAR(20)
)
    
BEGIN
    -- Delete the desired tuple
    DELETE FROM acl
    WHERE path = res_path AND acl.user = user AND permission = perm;
END !

DELIMITER ;

-- [Problem 1.4]

DROP PROCEDURE IF EXISTS clear_perms;

DELIMITER !

CREATE PROCEDURE clear_perms ()
    
BEGIN
    -- delete all permission entries
    DELETE FROM acl;
END !

DELIMITER ;

-- [Problem 1.5]

DROP FUNCTION IF EXISTS has_perm;

DELIMITER !

CREATE FUNCTION has_perm (
    res_path VARCHAR(1000), 
    user VARCHAR(20), 
    perm VARCHAR(20)
) RETURNS BOOLEAN
    
BEGIN
    -- declare variable to store the access (grant or deny)
    DECLARE access_perm CHAR(1);
    DROP TEMPORARY TABLE IF EXISTS path_len;
    -- Find all paths in the database that contain the given 
    -- resource and are for the given user and permission. 
    -- Also, find the length of these corresponding paths.
    CREATE TEMPORARY TABLE path_len 
        SELECT path, LENGTH(path) AS len, access 
		FROM acl
		WHERE CONCAT(res_path, '/') LIKE CONCAT(path,'/%') AND acl.user = user AND 
            permission = perm;
	-- Find the longest path length, as this will hold the 
    -- highest precedence over the permission of this 
    -- user. 
    SELECT access
    FROM path_len 
    WHERE len = (
        SELECT MAX(len)
        FROM path_len) INTO access_perm;
	-- Return a BOOLEAN properly based on access.
    IF access_perm = 'G' THEN 
        RETURN TRUE;
	ELSE 
        RETURN FALSE;
	END IF;
        
END !

DELIMITER ;
