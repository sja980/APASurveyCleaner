/*  
The latest .csv file can be exported from: 'https://apasurvey.philx.org/surveys' 
    
To run:
Execute all queries and export clean data from the 'apa2024' table.
	OR
Scroll through and uncomment SELECT functions as desired.
*/

/*
    1. CREATING DATABASE, TABLE AND LOADING RAW DATA FROM 'APA Journal Survey.csv' FILE
*/

--  Creates database --
CREATE DATABASE apasurveys;

--  Creates table --
CREATE TABLE apasurveys.apa2024(
    id INT NOT NULL AUTO_INCREMENT,
    Journal_name VARCHAR(150) NOT NULL,
    Create_date VARCHAR (50) NOT NULL,
    Gender VARCHAR (50),
    Demographics VARCHAR (100),
    Comment_count VARCHAR (50),
    Comment_quality VARCHAR (50),
    Editor_experience VARCHAR (50),
    Professional_status VARCHAR (50),
    Verdict VARCHAR (50),
    Second_verdict VARCHAR (50),
    Response_time VARCHAR (50),
    Acpt_to_pub VARCHAR (50),
    Acpt_date VARCHAR (50),
    Comments VARCHAR (5000),
    PRIMARY KEY (id)
);

--  Addresses error when using MySQL: "The MySQL server is running with the --secure-file-priv option so it cannot execute this statement": Move the .csv file to the directory shown when running the below script to solve --
--  SHOW VARIABLES LIKE "secure_file_priv";

--  Loads data from the .csv file into apasurveys.apa2024 table: in my case 9426 rows loaded 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/APA Journal Surveys.csv'
INTO TABLE apasurveys.apa2024
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Journal_name, Create_date, Gender, Demographics, Comment_count, Comment_quality, Editor_experience, Professional_status, Verdict, Second_verdict, Response_time, Acpt_to_pub, Acpt_date,  Comments); 

--  Displays the raw data loaded into the table
-- SELECT * FROM apasurveys.apa2024;

/*
    2. REMOVING UNUSED COLUMNS
*/

ALTER TABLE apasurveys.apa2024
	DROP COLUMN Acpt_to_pub;

ALTER TABLE apasurveys.apa2024
	DROP COLUMN Acpt_date;

ALTER TABLE apasurveys.apa2024
	DROP COLUMN Comments;
    
/*
    3. STANDARDISING '0', '', and NULL values
*/

-- Allows table updates without KEY column --
SET SQL_SAFE_UPDATES = 0;

UPDATE apasurveys.apa2024
    SET Gender = NULL
    WHERE Gender = '';
    
UPDATE apasurveys.apa2024
    SET Demographics = NULL
    WHERE Demographics = '';

-- Comment_count column contains both 0 and empty values. Setting empty to 0 to standardise
-- This relates to the subsequent cleanup of the relationship between Comment_count and Comment_quality; it's assumed safest to remove both NULL and empty values when there is also a Comment_quality value recorded.
UPDATE apasurveys.apa2024
    SET Comment_count = 0
    WHERE Comment_count = '';
    
UPDATE apasurveys.apa2024
    SET Comment_quality = NULL
    WHERE Comment_quality = '';
    
UPDATE apasurveys.apa2024
    SET Editor_experience = NULL
    WHERE Editor_experience = '';
    
UPDATE apasurveys.apa2024
    SET Second_verdict = NULL
    WHERE Second_verdict = '';

-- Response_time column contains both 0 and empty values. Setting empty to 0 to standardise
-- This relates to the subsequent removal of entries with 0 Response_time values as both NULL and 0 values are removed. 
UPDATE apasurveys.apa2024
    SET Response_time = 0
    WHERE Response_time = '';

ALTER TABLE apasurveys.apa2024
	MODIFY COLUMN Comment_count INT NOT NULL;

/*
    4. CLEANING ANOMALOUS DATA ENTRIES
*/

--  Checks (then removes) anomalous relationship between Comment_count = 0 and Comment_quality != NULL: in my case 231 rows deleted --
/*	SELECT Comment_count, Comment_quality FROM apasurveys.apa2024
	WHERE Comment_count = 0
    AND Comment_quality != 0;*/

DELETE FROM apasurveys.apa2024
    WHERE Comment_count = 0
    AND Comment_quality != 0;

--  Checks (then removes) anomalous Responce_time of 0: in my case 280 rows deleted
/*	SELECT * FROM apasurveys.apa2024
    WHERE Response_time = 0;*/
    
DELETE FROM apasurveys.apa2024
    WHERE Response_time = 0;
    
-- Checks (then removes) anomalous Repsonce_time of greater than 5 years: in my case 7 rows deleted
/*	SELECT * FROM apasurveys.apa2024
    WHERE Response_time > 60;*/
    
DELETE FROM apasurveys.apa2024
    WHERE Response_time > 60;
    
ALTER TABLE apasurveys.apa2024
	MODIFY COLUMN Response_time DECIMAL (10, 2) NOT NULL;

/*
    5. CHECKING FOR AND MERGING ENTRIES FOR JOURNALS WITH NAME VARIATIONS
*/

--  Lists all journal names alphabetically to see obvious variants --
/*	SELECT DISTINCT Journal_name
    FROM apasurveys.apa2024
    GROUP BY Journal_name
    ORDER BY Journal_name ASC;*/

-- Dao --
UPDATE apasurveys.apa2024
    SET Journal_name = 'Dao'
    WHERE Journal_name = 'Dao: A Journal of Comparative Philosophy';

-- Episteme --
UPDATE apasurveys.apa2024
    SET Journal_name = 'Episteme'
    WHERE Journal_name = 'Episteme: Journal of Social Epistemology';
    
-- Ergo --
UPDATE apasurveys.apa2024
    SET Journal_name = 'Ergo'
    WHERE Journal_name = 'Ergo an Open Access Journal of Philosophy'
    OR Journal_name = 'Ergo: an Open Access Journal of Philosophy';

-- Philosophers' Imprint --
UPDATE apasurveys.apa2024
    SET Journal_name = 'Philosophers\' Imprint'
    WHERE Journal_name = 'Philosophers’ Imprint';

-- Nous --
UPDATE apasurveys.apa2024
    SET Journal_name = 'Nous'
    WHERE Journal_name = 'Noûs';

-- Inquiry --
UPDATE apasurveys.apa2024
	SET Journal_name = 'Inquiry'
    WHERE Journal_name = 'Inquiry: An Interdisciplinary Journal of Philosophy';

-- Journal of Ethics & Social Philosophy --
UPDATE apasurveys.apa2024
	SET Journal_name = 'Journal of Ethics & Social Philosophy'
    WHERE Journal_name = 'Journal of Ethics and Social Philosophy';

-- Philosophia --
UPDATE apasurveys.apa2024
	SET Journal_name = 'Philosophia'
    WHERE Journal_name = 'Philosophia: Philosophical Quarterly of Israel';
    
-- Politics, Philosophy & Economics --
UPDATE apasurveys.apa2024
	SET Journal_name = 'Politics, Philosophy & Economics'
    WHERE Journal_name = 'Politics, Philosophy, and Economics'
    OR Journal_name = 'Politics, Philosophy and Economics'
    OR Journal_name = 'Politics Philosophy and Economics';

-- Thought --
UPDATE apasurveys.apa2024
	SET Journal_name = 'Thought'
    WHERE Journal_name = 'Thought: A Journal of Philosophy';
    
-- Studies in the History and Philosophy of Science (Parts A, B, C now one journal: Merging all entries so there is at least some historical data for this journal)
UPDATE apasurveys.apa2024
	SET Journal_name = 'Studies in the History and Philosophy of Science'
    WHERE Journal_name = 'Studies in History and Philosophy of Science Part A' 
    OR Journal_name ='Studies in History and Philosophy of Science Part B: Studies in History and Philosophy of Modern Physics' 
    OR Journal_name = 'Studies in History and Philosophy of Science Part C: Studies in History and Philosophy of Biological and Biomedical Science';

/*-
    6. Checks (then removes) journals with <10 entries
*/

-- Shows journals that will be affected
/*	SELECT Journal_name, COUNT(*) FROM apasurveys.apa2024
    GROUP BY Journal_name
    HAVING COUNT(*) < 10
    ORDER BY Journal_name ASC;*/
    
--  Shows entires that will be affected
/*	Select * FROM apasurveys.apa2024
    WHERE Journal_name in 
    (SELECT Journal_name FROM apasurveys.apa2024 GROUP BY Journal_name HAVING count(*) < 10);*/

--  Deletes entries: in my case 169 journals & 403 rows deleted
DELETE FROM apasurveys.apa2024
    WHERE Journal_name in 
    (SELECT Journal_name FROM (SELECT Journal_name FROM apasurveys.apa2024 GROUP BY Journal_name HAVING count(*) < 10) AS Journal_name);

/*-
    7. Shows some basic results
*/

-- Total table of surveys
SELECT * FROM apasurveys.apa2024;

-- Number of survey remainng after clean: in my case 8504
SELECT Count(*) FROM apasurveys.apa2024;

-- List of journals 
SELECT Journal_name FROM apasurveys.apa2024
GROUP BY Journal_name
ORDER BY Journal_name ASC;
