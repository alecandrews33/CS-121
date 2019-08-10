-- [Problem 1.3]

DROP TABLE IF EXISTS uses;
DROP TABLE IF EXISTS sw_package;
DROP TABLE IF EXISTS basic;
DROP TABLE IF EXISTS preferred;
DROP TABLE IF EXISTS account;
DROP TABLE IF EXISTS shared;
DROP TABLE IF EXISTS dedicated;
DROP TABLE IF EXISTS server;
DROP TABLE IF EXISTS has_installed;


CREATE TABLE has_installed (
    -- The hostname of the server involved.
    hostname VARCHAR(40),
    -- The software package name installed on the particular server.
    package_name VARCHAR(40),
    -- The software package version installed on the particular server.
    version VARCHAR(20),
    -- Many to many relationship makes primary key the union of the
    -- primary keys of the two involved entities. 
    PRIMARY KEY (hostname, package_name, version)
);

CREATE TABLE server (
    -- The hostname of the server. This is required to
    -- be unique and thus is a primary key. This is 
    -- a foreign key to has_installed.hostname
    hostname VARCHAR(40) PRIMARY KEY REFERENCES
        has_installed (hostname) ON DELETE CASCADE
        ON UPDATE CASCADE,
    -- Operating system that is being run on the server.
    operating_sys VARCHAR(30) NOT NULL
);

CREATE TABLE shared (
    -- The hostname of the shared server. Foreign key to 
    -- hostname in server relation. Primary key.
    hostname VARCHAR(40) PRIMARY KEY REFERENCES server (hostname)
        ON DELETE CASCADE ON UPDATE CASCADE,
    -- The maximum number of sites that can be held on 
    -- this server.
    max_sites INTEGER NOT NULL,
    -- Make sure that max_sites > 1 since this is a shared server.
    CHECK (max_sites > 1)
);

CREATE TABLE dedicated (
    -- The hostname of the dedicated server. Foreign key to 
    -- hostname in server relation. Primary key.
    hostname VARCHAR(40) PRIMARY KEY REFERENCES server (hostname)
        ON DELETE CASCADE ON UPDATE CASCADE,
    -- The maximum number of sites that can be held on
    -- this server.
    max_sites INTEGER NOT NULL,
    -- Make sure that max_sites = 1 since this is a dedicated server.
    CHECK (max_sites = 1)
);

CREATE TABLE account (
    -- The username associated with the account. Primary key.
    username VARCHAR(20) PRIMARY KEY,
    -- Account type. This will be either B or P, denoting whether
    -- the account is basic or preferred.
    account_type CHAR(1) NOT NULL,
    -- The email for the customer account.
    email VARCHAR(70) NOT NULL,
    -- The website url. Candidate key.
    url VARCHAR(200) NOT NULL UNIQUE,
    -- The timestamp that the customer opened an account.
    time_stamp TIMESTAMP NOT NULL,
    -- Monthly subscription price that the customer must pay.
    price NUMERIC(8, 2) NOT NULL,
    -- Check that account_type is either B or P.
    CHECK (account_type IN ('B', 'P'))
);

CREATE TABLE basic (
    -- The username associated with the account. Primary key.
    username VARCHAR(20) NOT NULL PRIMARY KEY,
	-- Account type. This will be B denoting that the account is basic.
    account_type CHAR(1) NOT NULL,
    -- The hostname of the shared server that the basic account is on.
    hostname VARCHAR(40) NOT NULL REFERENCES shared (hostname)
        ON DELETE CASCADE ON UPDATE CASCADE,
    -- Foreign key for username, account_type on accoutn relation. 
    FOREIGN KEY (username, account_type) REFERENCES 
        account (username, account_type) ON DELETE CASCADE
        ON UPDATE CASCADE,
	-- Make sure that the account_type is B for basic account.
	CHECK (account_type = 'B')
);

CREATE TABLE preferred (    
    -- The username associated with the account. Primary key.
    username VARCHAR(20) NOT NULL PRIMARY KEY,
    -- Account type. This will be B denoting that the account is basic.
    account_type CHAR(1) NOT NULL,
    -- The hostname of the shared server that the basic account is on.
    hostname VARCHAR(40) NOT NULL REFERENCES dedicated (hostname)
        ON DELETE CASCADE ON UPDATE CASCADE,
    -- Foreign key for username, account_type to account relation.
    FOREIGN KEY (username, account_type) REFERENCES 
        account (username, account_type) ON DELETE CASCADE
        ON UPDATE CASCADE,
	-- Make sure that account_type is preferred.
	CHECK (account_type = 'P'),
    -- hostname is a candidate key.
	UNIQUE(hostname)
);


CREATE TABLE sw_package (
    -- The software package name
    package_name VARCHAR(40) NOT NULL,
    -- The version of the software package
    version VARCHAR(20) NOT NULL,
    -- A brief description of the package
    description VARCHAR(1000),
    -- Monthly price that customers must pay for using the package.
    cost NUMERIC(8, 2),
    -- Package name and version must be unique, this is the primary key.
    PRIMARY KEY (package_name, version),
    -- Constrain foreign key on package name and version.
    FOREIGN KEY (package_name, version) REFERENCES 
        has_installed (package_name, version) ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE uses (
    -- The username from the account that uses the software.
    -- Foreign key to account.username
    username VARCHAR(20) REFERENCES account (username)
        ON DELETE CASCADE ON UPDATE CASCADE,
    -- The package name of the software. 
    package_name VARCHAR(40),
    -- The version of the software package
    version VARCHAR(20),
    -- Many to many relationship makes primary key the union of the
    -- primary keys of the two involved entities. 
    PRIMARY KEY (username, package_name, version),
    -- Constrain foreign key for package_name, version on 
    -- sw_package.package_name and sw_package.version
    FOREIGN KEY (package_name, version) REFERENCES 
        sw_package (package_name, version) ON DELETE CASCADE
        ON UPDATE CASCADE
);


    