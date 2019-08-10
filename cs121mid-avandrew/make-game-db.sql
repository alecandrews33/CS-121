-- [Problem 1]

DROP TABLE IF EXISTS game_score;
DROP TABLE IF EXISTS game;
DROP TABLE IF EXISTS game_type;
DROP TABLE IF EXISTS geezer;

-- [Problem 2]

CREATE TABLE geezer (
    -- Auto generated person ID that is Primary Key
    person_id INTEGER AUTO_INCREMENT PRIMARY KEY,
    -- At most 100 characters
    person_name VARCHAR(100) NOT NULL,
    -- This value will be either M or F
    gender CHAR NOT NULL, 
    -- Just a date, not a time
    birth_date DATE NOT NULL,
    -- Can be null, or up to 1000 characters
    prescriptions VARCHAR(1000),
    -- Make sure that the gender is M or F
    CHECK (gender IN
                      ('M', 'F'))
);

CREATE TABLE game_type (
    -- Auto generated type ID that is primary key
    type_id INTEGER AUTO_INCREMENT PRIMARY KEY,
    -- The name of the type of game, up to 20 characters
    type_name VARCHAR(20) NOT NULL,
    -- Description of game type. Can be up to 1000 characters
    game_desc VARCHAR(1000) NOT NULL,
    -- The minimum number of players, can't be NULL
    min_players INTEGER NOT NULL,
    -- The maximum number of players, can be NULL if there's no max
    max_players INTEGER,
    -- Make sure the game requires at least 1 player
    CHECK (min_players >= 1),
    -- Make sure that max_players is either NULL or greater than / equal
    -- to the min_players
    CHECK (max_players IS NULL OR max_players >= min_players)
);

CREATE TABLE game (
    -- Auto generated game id that is primary key
    game_id INTEGER AUTO_INCREMENT PRIMARY KEY,
    -- Foreign key denoting the ID of the game type
    type_id INTEGER REFERENCES game_type (type_id),
    -- The date and time of the game
    game_date DATETIME NOT NULL
);

CREATE TABLE game_score (
    -- Foreign key of the game ID being played
    game_id INTEGER REFERENCES game (game_id),
    -- Foreign key of the person ID of who is playing
    person_id INTEGER REFERENCES geezer (person_id),
    -- The score in the given game of the given person
    score INTEGER NOT NULL,
    -- This primary key uniquely identifies each score
    PRIMARY KEY (game_id, person_id)
);