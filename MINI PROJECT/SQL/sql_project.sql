/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT DISTINCT name FROM Facilities WHERE membercost > 0

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(DISTINCT name) FROM Facilities WHERE membercost = 0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance FROM Facilities 
WHERE membercost < 0.2*monthlymaintenance

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */


SELECT * FROM Facilities WHERE facid in (1, 5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance, 
       CASE WHEN monthlymaintenance > 100 THEN 'expensive' ELSE 'cheap' END AS label
FROM Facilities 

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT sub.firstname, sub.surname FROM 
   (SELECT firstname, surname, MIN(joindate) FROM Members) sub

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT Facilities.name, CONCAT(firstname,' ', surname) as membername FROM Facilities JOIN 
  (SELECT surname, firstname, Members.memid, facid FROM Members JOIN Bookings ON Members.memid = Bookings.memid) mb
ON Facilities.facid = mb.facid
WHERE name LIKE 'Tennis Court%'
ORDER BY membername


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

Select b.bookid, f.name AS facility_name, CONCAT(m.firstname, ' ', m.surname) AS names,
CASE WHEN m.memid = 0 THEN f.guestcost * 2 * b.slots 
ELSE f.membercost * 2 * b.slots END as total_cost
FROM Bookings b , Facilities f , Members m 
WHERE b.facid = f.facid AND b.memid = m.memid
AND b.starttime BETWEEN '2012-09-04' AND '2012-09-04 23:59:59'
AND CASE WHEN m.memid = 0 THEN f.guestcost * 2 * b.slots 
ELSE f.membercost * 2 * b.slots END > 30
ORDER BY total_cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT Facilities.name, 
       memberbook.bookid, 
       memberbook.membername,
       CASE WHEN memberbook.memid = 0 THEN Facilities.guestcost * memberbook.slots*2
       ELSE Facilities.membercost* memberbook.slots*2 END AS total_cost,
       memberbook.starttime
FROM Facilities JOIN  

  (SELECT bookid, 
          CONCAT(firstname, surname) AS membername,
          Bookings.slots as slots, 
          Bookings.memid AS memid,
          Bookings.facid AS facid,
          Bookings.starttime AS starttime
   FROM Bookings
   LEFT JOIN Members ON Members.memid = Bookings.memid
   WHERE starttime BETWEEN '2012-09-04' AND '2012-09-04 23:59:59') memberbook

ON Facilities.facid = memberbook.facid
WHERE CASE WHEN memberbook.memid = 0 THEN Facilities.guestcost * memberbook.slots*2
ELSE Facilities.membercost* memberbook.slots*2 END > 30
ORDER BY total_cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT f.name AS facility_name,
SUM(CASE WHEN b.memid = 0 THEN f.guestcost*2*b.slots 
ELSE f.membercost*2*b.slots END) AS total_revenue
FROM Facilities f JOIN Bookings b
ON f.facid = b.facid
GROUP BY f.name
HAVING total_revenue < 1000
ORDER BY total_revenue
