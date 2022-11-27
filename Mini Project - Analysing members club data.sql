--I have worked with SQL to analyse data as part of my data analysis/science foundation.
--This piece of work was compiled using PostgreSQL. The data was imported from a .tar file and the tables were created as part of the import process.
--The data displayed in the code surrounds a members club, including the facilities it offers.

SELECT * FROM cd.bookings; --Selecting relevant tables
SELECT * FROM cd.facilities;
SELECT * FROM cd.members;

--1. Retrieve all information from the cd.facilities table.
SELECT * from cd.facilities;

--2. Print a list of all facilities and their cost.
SELECT name,membercost,guestcost 
FROM cd.facilities;

--3. Produce a list of facilities that charge a fee to members.
SELECT * from cd.facilities
WHERE membercost > 0; -- Displaying all facilities where there is a cost to members

--4. Produce a list of facilities that charge a fee to members, and that fee is less
--than 1/50ths of the monthly maintenance cost? 
SELECT facid,name,membercost,monthlymaintenance --Select columns
FROM cd.facilities -- From relevant table
WHERE membercost > 0 AND membercost < (0.02*monthlymaintenance); --Where the member cost is greater than 0 and where the cost is less than 1/50th the monthly maintenance.

--5. Produce a list of all facilities with tennis in their name
SELECT name 
FROM cd.facilities
WHERE name LIKE '%Tennis%'; --I use LIKE %Tennis% to highlight all sports that contain 'Tennis' in their name.

--6. How can you retrieve the details with ID1 and ID5
SELECT * FROM cd.facilities
WHERE facid IN(1,5); --Use of IN to highlight 1 and 5
--OR
SELECT * FROM cd.facilities
WHERE facid = 1 OR facid = 5;  -- Use of OR to highlight 1 and 5

--7. What is the number of members who joined after September 2012?
SELECT memid, surname, firstname, joindate 
FROM cd.members
WHERE joindate BETWEEN '2012-09-01' AND NOW(); --Select joindates between 2012-09-01 and now.

--8. Produce a list of the first ten surnames in the members table. The list must not contain duplicates.
SELECT DISTINCT(surname)
FROM cd.members
ORDER BY surname ASC -- ORDER by surname in ascending order
LIMIT 10; --Limit the output to the top 10

--9. What is the signup date of your last member?
SELECT joindate
FROM cd.members
ORDER BY joindate DESC -- Order by join date in descending order, displaying the newest members first.
LIMIT 1; --Order the output to 1 e.g., the newest member

--10. Produce a count of the facilities that have a cost to the guests of 10 or more.
SELECT COUNT(name)
FROM cd.facilities
WHERE guestcost > 10.00; -- Display facilities where guestcost is >10 for a facility.

--11. Produce a list of the total number of slots booked per facility in the month of September 2012. 
--Produce an output table consisting of facility id and slots, sorted by the number of slots.

SELECT SUM(slots), facid -- Counting the number of slots per facid. I then groupby facid to count the slots per facid
FROM cd.bookings
WHERE starttime >= '2012-09-01' AND starttime < '2012-10-01'
GROUP BY facid
ORDER BY SUM(slots); --Order by the sum of slots

--12. Produce a list of facilities with more than 1000 slots booked.
--Produce an output table consisting of facid and total slots, sorted by facility id

SELECT facid, SUM(slots) AS total_slots
FROM cd.bookings
GROUP BY facid
HAVING SUM(slots) > 1000 --Use having >1000 as we can't use where with an aggregate in the SELECT clause.
ORDER BY SUM(slots) DESC; 

--13. Produce a lsit of the start times for bookings for tennis courts for the date 2012-09-21. Return a list of start time and facility
--name pairings, ordered by the time

SELECT bookings.starttime, facilities.name
FROM cd.bookings
INNER JOIN cd.facilities --Use inner join as facid is present in both tables.
ON cd.bookings.facid = cd.facilities.facid --Join the tables on the same column
WHERE facilities.name IN ('Tennis Court 1', 'Tennis Court 2') -- Selecting Tennis court 1 and 2
AND starttime BETWEEN '2012-09-21 00:00:00' AND '2012-09-21 23:59:59' --Viewing starttimes for this date 2012-09-21
ORDER BY bookings.starttime;

--14. Produce a list of the start times for bookings by members named
--'David Farrell'
SELECT bookings.starttime
FROM cd.bookings
INNER JOIN cd.members --Use inner join as memid is present in both tables
ON cd.bookings.memid = cd.members.memid --join the tables on the same column
WHERE members.firstname = 'David' AND members.surname = 'Farrell';  --Where name = David Farrell

