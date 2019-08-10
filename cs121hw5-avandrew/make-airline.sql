-- [Problem 5]

-- DROP TABLE commands:

DROP TABLE IF EXISTS seat_ticket;
DROP TABLE IF EXISTS flights;
DROP TABLE IF EXISTS seats;
DROP TABLE IF EXISTS aircraft;
DROP TABLE IF EXISTS ticket;
DROP TABLE IF EXISTS purchase;
DROP TABLE IF EXISTS purchaser;
DROP TABLE IF EXISTS traveler;
DROP TABLE IF EXISTS consumer_phone;
DROP TABLE IF EXISTS consumer;

-- CREATE TABLE commands:

-- This table stores all flights on all days. A date and a flight number make
-- up the primary key. There is a foreign key to type_code to maintain the
-- relationship between aircraft and flights.

CREATE TABLE flights (
    flight_number VARCHAR(10),
    flight_date DATE,
    flight_time TIME NOT NULL,
    departure CHAR(3) NOT NULL,
    arrival CHAR(3) NOT NULL,
    flight_type CHAR(1) NOT NULL,
    type_code CHAR(3) REFERENCES aircraft (type_code),
    PRIMARY KEY (flight_number, flight_date),
    CHECK (flight_type IN ('D', 'I'))
);

-- This table stores information about different available aircraft. The
-- primary key is the IATA type code.

CREATE TABLE aircraft (
    type_code CHAR(3) PRIMARY KEY,
    manufacturer VARCHAR(20) NOT NULL,
    model VARCHAR(20) NOT NULL
);

-- This table stores information about seats available for a given aircraft.
-- The foreign key type_code specifies which aircraft is involved. The 
-- primary key is a type_code and a seat number. If exit_row is True,
-- that seat is in an exit row.

CREATE TABLE seats (
    type_code CHAR(3) REFERENCES aircraft (type_code),
    seat_number CHAR(4) NOT NULL,
    seat_class CHAR(1) NOT NULL,
    seat_type CHAR(1) NOT NULL,
    exit_row BOOLEAN NOT NULL,
    PRIMARY KEY (type_code, seat_number),
    CHECK (seat_class IN ('F', 'B', 'C')),
    CHECK (seat_type IN ('A', 'M', 'W'))
);

-- This table stores information about the consumers. The primary
-- key is an automatically updated integer. 

CREATE TABLE consumer (
    consumer_ID INTEGER AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    email VARCHAR(30) NOT NULL
);

-- This table is necessary as people can have multiple phone numbers.
-- The consumer_ID comes from the consumer relation. The primary key 
-- is a consumer_ID and a phone_number. 

CREATE TABLE consumer_phone (
    consumer_ID INTEGER REFERENCES consumer (consumer_ID),
    phone_number CHAR(10),
    PRIMARY KEY (consumer_ID, phone_number)
);

-- This table stores information about purchases made by purchasers. 
-- The foreign key consumer_ID indicates who is the purchaser. The 
-- primary key is an automaticlaly updated integer. 

CREATE TABLE purchase (
    purchase_ID INTEGER AUTO_INCREMENT PRIMARY KEY,
    purchase_date DATETIME NOT NULL,
    confirmation_number CHAR(6) NOT NULL,
    consumer_ID INTEGER REFERENCES consumer (consumer_ID)
);

-- This table stores information about the purchasers. The primary key 
-- is the consumer_ID of the particular purchaser making the purchase.
-- Note that YEAR can be used for expiration date if values are represented
-- as MMYY. 

CREATE TABLE purchaser (
    consumer_ID INTEGER PRIMARY KEY REFERENCES consumer (consumer_ID),
    card_number CHAR(16),
    expiration_date YEAR,
    verification_code CHAR(3)
);

-- This table stores information about travelers. The primary key is the 
-- consumer_ID from consumer. The rest of the information can be NULL.

CREATE TABLE traveler (
    consumer_ID INTEGER PRIMARY KEY REFERENCES consumer (consumer_ID),
    frequent_flyer CHAR(7),
    passport_number VARCHAR(40),
    citizen_of VARCHAR(25),
    emergency_contact VARCHAR(30),
    emergency_phone CHAR(10)
);

-- This table stores information about tickets that have been bought. 
-- The primary key is an automatically incremented integer. The 
-- foreign key (purchase_ID, consumer_ID) comes from purchase.

CREATE TABLE ticket (
    ticket_ID INTEGER AUTO_INCREMENT PRIMARY KEY,
    sale_price NUMERIC(6, 2) NOT NULL,
    purchase_ID INTEGER REFERENCES purchase (purchase_ID),
    consumer_ID INTEGER REFERENCES consumer (consumer_ID)
);

-- This table stores information about the relationship between seats,
-- flights, and tickets. One ticket represents one seat for one flight, 
-- so we have foreign keys that are primary keys from flights and
-- seats. Also, ticket_ID is a candidate key, and a foreign key from ticket.

CREATE TABLE seat_ticket (
    flight_number VARCHAR(10) NOT NULL,
    flight_date DATE NOT NULL,
    type_code CHAR(3) NOT NULL,
    seat_number CHAR(4) NOT NULL,
    ticket_ID INTEGER REFERENCES ticket (ticket_ID),
    FOREIGN KEY (flight_number, flight_date) REFERENCES
        flights (flight_number, flight_date),
	FOREIGN KEY (type_code, seat_number) REFERENCES
        seats (type_code, seat_number),
	PRIMARY KEY (flight_number, flight_date, type_code, seat_number),
    UNIQUE(ticket_ID)
);
    
