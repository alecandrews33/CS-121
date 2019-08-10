-- [Problem 1]

DROP TABLE IF EXISTS owns;
DROP TABLE IF EXISTS participated;
DROP TABLE IF EXISTS person;
DROP TABLE IF EXISTS car;
DROP TABLE IF EXISTS accident;

CREATE TABLE participated (
-- The driver's identification number. Foreign Key from person table. 
-- Cascade updates, not deletes.
    driver_id CHAR(10) REFERENCES person(driver_id)
									ON UPDATE CASCADE,
-- The car's license number. Foreign Key from car table.
-- Cascade updates, not deletes. 
    license CHAR(7) REFERENCES car(license)
								ON UPDATE CASCADE,
-- The accident report number. Foreign Key from accident table. 
    report_number INT REFERENCES accident(report_number)
									ON UPDATE CASCADE,
-- The monetary value of damage in the accident. Can be NULL.
    damage_amount NUMERIC(12, 2),
-- Unique identifiers include ID, license, and report_number. 
    PRIMARY KEY(driver_id, license, report_number)
);

CREATE TABLE owns (
-- The driver's identification number. Foreign Key from person table. 
-- Cascade updates and deletes.
    driver_id CHAR(10) REFERENCES person (driver_id)
									ON DELETE CASCADE
									ON UPDATE CASCADE,
-- The car's license number. Foreign Key from car table.
-- Cascde updates and deletes.
    license CHAR(7) REFERENCES car (license)
								ON DELETE CASCADE
								ON UPDATE CASCADE,
-- Driver ID and license number make up a unique key.
	PRIMARY KEY(driver_id, license)
);

CREATE TABLE accident (
-- The accident report number. Primary Key. Auto Increments. 
    report_number INTEGER AUTO_INCREMENT PRIMARY KEY, 
-- The date and time the accident occurred. 
    date_occurred DATETIME NOT NULL, 
-- The location of the accident.
    location VARCHAR(100) NOT NULL, 
-- The description of the accident by the one reporting. Can be NULL.
    description TEXT
);

CREATE TABLE car (
-- The car's license number. Primary Key.
    license CHAR(7) PRIMARY KEY,
-- The model of the car. Can be NULL.
    model VARCHAR(30), 
-- The year the car was made. Can be NULL.
    year YEAR
);

CREATE TABLE person (
-- The driver's identification number.
    driver_id CHAR(10) PRIMARY KEY,
-- The name of the driver. 
    name VARCHAR(30) NOT NULL,
-- The address of the driver. 
    address VARCHAR(100) NOT NULL
    );
