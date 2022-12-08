-- This analysis is to demonstrate analyitucal use of SQL. 
-- The data obtained for this dataset was captured from Kaggle. This data refers to 120 years of Olympic History from Athens 1896 to Rio 2016. The data includes Summer and Winter games.
-- There are lots of interesting questions that can be answered, including which country has won the most medals, which athletes have won the most medals, is representation improving in Olympic sports, amongst many more.
-- The data can be  located here: https://www.kaggle.com/datasets/heesoo37/120-years-of-olympic-history-athletes-and-results
-- To begin, I have to create two tables before importing my CSV data. I am using Microsoft SQL Server for this analysis as I had considerable problems loading data into PostgreSQL.

-- Creating our first table.
CREATE TABLE OLYMPICS_HISTORY -- Calling our table OLYMPICS_HISTORY
(
	id		INT, -- Use an integer for ID. Typically, here I would use SERIAL and PRIMARY KEY, but it is not relevant here as the data has already been generated and we are simply importing.
	name	VARCHAR(150), -- I have set each data type to a var char(150) as some individuals had long names, some events have long names as do events.
	sex		VARCHAR(150),
	age		VARCHAR(150), 
	height	VARCHAR(150), -- I would like to have included a SMALLINT for height and weight to calculate average height and weight of certain athletes over a period of time, but errors arise when I do.
	weight	VARCHAR(150),
	team	VARCHAR(150),
	noc		VARCHAR(150),
	games	VARCHAR(150),
	year	DATE,
	season	VARCHAR(150),
	city	VARCHAR(150),
	sport	VARCHAR(150),
	event	VARCHAR(200),
	medal	VARCHAR(150)
);
DROP TABLE OLYMPICS_HISTORY -- I have included a drop table query as it makes updating table parameters much easier.

BULK INSERT OLYMPICS_HISTORY -- This bulk query inserts data into the columns straight from the path given.
FROM 'C:\Users\Andrew\Desktop\SQL\athlete_events.csv'
WITH (
	FORMAT = 'CSV', -- Specify CSV file.
	FIRSTROW = 2, -- Specify we want the first row to be the second as the first contains headers, not data.
	FIELDTERMINATOR=',', -- Separate columns by a comma
	ROWTERMINATOR='\n' -- When a new the end of a row is triggered, move to the next
);

CREATE TABLE OLYMPICS_HISTORY_NOC_REGIONS -- Creating the second table
(
	noc		VARCHAR(150), -- As above. VARCHAR(150) is long enough to include all regions.
	region	VARCHAR(150),
	notes	VARCHAR(150),
PRIMARY KEY (noc)
);
DROP TABLE OLYMPICS_HISTORY_NOC_REGIONS

BULK INSERT OLYMPICS_HISTORY_NOC_REGIONS -- INSERT DATA INTO COLUMNS USING BULK INSERT STRAIGHT FROM PATH
FROM 'C:\Users\Andrew\Desktop\SQL\noc_regions.csv'
WITH (
	FIRSTROW = 2, 
	FIELDTERMINATOR=',', 
	ROWTERMINATOR='\n' 
);

SELECT * FROM OLYMPICS_HISTORY; -- Checking the data has been correctly imported.
SELECT * FROM OLYMPICS_HISTORY_NOC_REGIONS; -- Checking the data has been correctly imported.

-- Now that the data has been imported and the tables have been created, ad-hoc analysis can be conducted.
-- 1. Find the total number of Summer Olympic Games

SELECT 
    COUNT(DISTINCT (games))
FROM
    OLYMPICS_HISTORY
WHERE
    season = 'Summer'; -- 29 games

-- 2. Identify the number of sports which have been played in every Summer Olympics

SELECT 
    COUNT(DISTINCT (sport)), games
FROM
    OLYMPICS_HISTORY
WHERE
    games BETWEEN '1896 Summer' AND '2016 Summer'
        AND season = 'Summer'
GROUP BY games
ORDER BY COUNT(DISTINCT (sport))-- 9 in 1896. 34 from 2000-2016

-- 3. Identify which sports which have been played in every Summer Olympics
SELECT 
    sport, games, COUNT(*)
FROM
    OLYMPICS_HISTORY
WHERE
    season = 'Summer'
GROUP BY sport , games
ORDER BY COUNT(*) DESC;

-- 4. Which athlete has appeared the most in the Summer Olympics and for which sport?
SELECT 
    name, sport, COUNT(*)
FROM
    OLYMPICS_HISTORY
WHERE
    season = 'Summer'
GROUP BY name , sport
ORDER BY COUNT(*) DESC; --Heikki Ilmari Savolainen - Gymnastics


-- 5. Which 3 male athlete have received the most gold medals in the Winter Olympics and in what events?
SELECT 
    name, sex, COUNT(medal), event
FROM
    OLYMPICS_HISTORY
WHERE
    sex = 'm' AND season = 'Winter'
GROUP BY name , event , sex , medal
ORDER BY COUNT(medal) DESC
	OFFSET 0 ROWS
	FETCH NEXT 3 ROWS ONLY; -- Noriaki Kasai, Ilmrs Bricis, Lee Gyu-Hyeok

-- 6. Which 3 female athlete has received the most gold medals in the Winter Olympics and in what events?
SELECT 
    name, sex, COUNT(medal), event
FROM
    OLYMPICS_HISTORY
WHERE
    sex = 'f'
GROUP BY name , event , sex , medal
ORDER BY COUNT(medal) DESC
	OFFSET 5 ROWS -- I offset the first 5 rows and include 5 more as there are art competition data included with medals. This returns the 3 athletes.
	FETCH NEXT 5 ROWS ONLY;

-- 7. Who is, how old and what event did the youngest male and female recipients of a podium finish in the Summer Olympics?
SELECT 
    name, age, medal, event, year
FROM
    OLYMPICS_HISTORY
WHERE
    medal IN ('Bronze' , 'Silver', 'Gold')
GROUP BY name , age , medal , event , year
ORDER BY AGE ASC
	OFFSET 0 ROWS
	FETCH NEXT 1 ROWS ONLY; -- A 10 year old named Dimitros Loundras won a bronze medal in 1896 in the Men's Parallel Bars, Teams

-- 8. Who won the most medals in the 1976 Summer Olympics?
SELECT 
    name, sport, COUNT(medal) AS Medal_Count
FROM
    OLYMPICS_HISTORY
WHERE
    games = '1976 Summer'
GROUP BY name , sport
ORDER BY COUNT(medal) DESC
	OFFSET 0 ROWS
	FETCH NEXT 1 ROWS ONLY; -- 72 gymnasts won 8 medals. Zero won 9 or above.

-- 9. Has there been an increase in the number of female competitors from 1976-2004?
SELECT 
    COUNT(sex), games
FROM
    OLYMPICS_HISTORY
WHERE
    sex = 'f'
        AND games IN ('1976 Summer' , '1980 Summer',
        '1984 Summer',
        '1988 Summer',
        '1992 Summer',
        '1996 Summer',
        '2000 Summer',
        '2004 Summer')
GROUP BY games
ORDER BY games; -- There is a sharp rise in female competitors every year from 1980 -2004. 1980 has 1756 athletes and 2004 has 5546 athletes.

-- 10. Which five countries have won the most medals? I will limit the answer to the top5.
SELECT 
    OLYMPICS_HISTORY_NOC_REGIONS.region,
    COUNT(OLYMPICS_HISTORY.medal)
FROM
    OLYMPICS_HISTORY_NOC_REGIONS
        INNER JOIN
    OLYMPICS_HISTORY ON OLYMPICS_HISTORY_NOC_REGIONS.noc = OLYMPICS_HISTORY.noc
WHERE
    OLYMPICS_HISTORY.medal IN ('Bronze' , 'Silver', 'Gold')
GROUP BY OLYMPICS_HISTORY_NOC_REGIONS.region
ORDER BY COUNT(OLYMPICS_HISTORY.medal) DESC
	OFFSET 0 ROWS
	FETCH NEXT 5 ROWS ONLY; -- 1. USA, 5637 2. Russia, 3947, 3. Germany, 3756 4. UK, 2068, 5. France 1777

-- 11. Which sport are the UK best at?
SELECT 
    OLYMPICS_HISTORY.sport,
    OLYMPICS_HISTORY_NOC_REGIONS.region,
    COUNT(OLYMPICS_HISTORY.medal)
FROM
    OLYMPICS_HISTORY
        INNER JOIN
    OLYMPICS_HISTORY_NOC_REGIONS ON OLYMPICS_HISTORY_NOC_REGIONS.noc = OLYMPICS_HISTORY.noc
WHERE
    OLYMPICS_HISTORY_NOC_REGIONS.region = 'UK'
GROUP BY OLYMPICS_HISTORY.sport , OLYMPICS_HISTORY_NOC_REGIONS.region
ORDER BY COUNT(OLYMPICS_HISTORY.medal) DESC
	OFFSET 0 ROWS
	FETCH NEXT 3 ROWS ONLY; -- The UK are best at Athletics with 2244 medals, their next best sport is Swimming with 1291 medals and Gymnastics are their third best with 1127 medals.

