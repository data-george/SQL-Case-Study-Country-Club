/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name 
FROM Facilities 
WHERE membercost > 0;

/*

name	
Tennis Court 1
Tennis Court 2
Massage Room 1
Massage Room 2
Squash Court

*/

/* Q2: How many facilities do not charge a fee to members? */

/* 4 */

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost < 0.2 * monthlymaintenance;

/* 

facid	name	membercost	monthlymaintenance	
0	Tennis Court 1	5.0	200
1	Tennis Court 2	5.0	200
2	Badminton Court	0.0	50
3	Table Tennis	0.0	10
4	Massage Room 1	9.9	3000
5	Massage Room 2	9.9	3000
6	Squash Court	3.5	80
7	Snooker Table	0.0	15
8	Pool Table	0.0	15

*/

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid
IN ( 1, 5 )

/*

facid	name	membercost	guestcost	initialoutlay	monthlymaintenance	
1	Tennis Court 2	5.0	25.0	8000	200
5	Massage Room 2	9.9	80.0	4000	3000

*/

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
CASE WHEN monthlymaintenance >100
THEN 'expensive'
WHEN monthlymaintenance <=100
THEN 'cheap'
END AS expensiveorcheap
FROM Facilities

/*

name	monthlymaintenance	expensiveorcheap	
Tennis Court 1	200	expensive
Tennis Court 2	200	expensive
Badminton Court	50	cheap
Table Tennis	10	cheap
Massage Room 1	3000	expensive
Massage Room 2	3000	expensive
Squash Court	80	cheap
Snooker Table	15	cheap
Pool Table	15	cheap

*/

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM Members
WHERE joindate
IN (

SELECT MAX( joindate )
FROM Members
)

/*

firstname	surname	
Darren	Smith

*/

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT F.name AS courtname, CONCAT( M.firstname, ' ', M.surname ) AS membername
FROM Members AS M
INNER JOIN Bookings AS B ON B.memid = M.memid
INNER JOIN Facilities AS F ON B.facid = F.facid
WHERE (
B.facid =0
OR B.facid =1
)
AND (
F.facid =0
OR F.facid =1
)
ORDER BY membername

/*

courtname	membername	
Tennis Court 1	Anne Baker
Tennis Court 2	Anne Baker
Tennis Court 1	Burton Tracy
Tennis Court 2	Burton Tracy
Tennis Court 2	Charles Owen
Tennis Court 1	Charles Owen
Tennis Court 2	Darren Smith
Tennis Court 1	David Farrell
Tennis Court 2	David Farrell
Tennis Court 1	David Jones
Tennis Court 2	David Jones
Tennis Court 1	David Pinker
Tennis Court 1	Douglas Jones
Tennis Court 1	Erica Crumpet
Tennis Court 2	Florence Bader
Tennis Court 1	Florence Bader
Tennis Court 1	Gerald Butters
Tennis Court 2	Gerald Butters
Tennis Court 1	GUEST GUEST
Tennis Court 2	GUEST GUEST
Tennis Court 2	Henrietta Rumney
Tennis Court 1	Jack Smith
Tennis Court 2	Jack Smith
Tennis Court 1	Janice Joplette
Tennis Court 2	Janice Joplette
Tennis Court 1	Jemima Farrell
Tennis Court 2	Jemima Farrell
Tennis Court 1	Joan Coplin
Tennis Court 1	John Hunt
Tennis Court 2	John Hunt

*/



/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT F.name AS facilityname, CONCAT( M.firstname, ' ', M.surname ) AS membername,
CASE WHEN F.membercost >30
AND M.memid <>0
THEN F.membercost * B.slots
WHEN F.guestcost >30
AND M.memid =0
THEN F.guestcost * B.slots
END AS cost
FROM Members AS M
LEFT JOIN Bookings AS B ON B.memid = M.memid
LEFT JOIN Facilities AS F ON B.facid = F.facid
WHERE DATE( B.starttime ) = '2012-09-14'
ORDER BY cost DESC
LIMIT 4

/*


facilityname	membername	cost	
Massage Room 2	GUEST GUEST	320.0
Massage Room 1	GUEST GUEST	160.0
Massage Room 1	GUEST GUEST	160.0
Massage Room 1	GUEST GUEST	160.0

*/


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT  cst.facilityname, CONCAT( cst.firstname, ' ', cst.surname ) AS membername, cst.cost

FROM 
    
(
    
SELECT F.name AS facilityname, M.firstname, M.surname,
    
CASE WHEN F.membercost >30
AND M.memid <>0
THEN F.membercost * B.slots
WHEN F.guestcost >30
AND M.memid =0
THEN F.guestcost * B.slots
END AS cost  

FROM Members AS M
LEFT JOIN Bookings AS B ON B.memid = M.memid
LEFT JOIN Facilities AS F ON B.facid = F.facid
WHERE DATE( B.starttime ) = '2012-09-14'

) AS cst

WHERE cost IS NOT NULL
ORDER BY cost DESC;

/*

facilityname	membername	cost	
Massage Room 2	GUEST GUEST	320.0
Massage Room 1	GUEST GUEST	160.0
Massage Room 1	GUEST GUEST	160.0
Massage Room 1	GUEST GUEST	160.0

*/


/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT rev.facilityname, SUM( rev.revenue ) AS total_revenue
FROM (

SELECT F.name AS facilityname,
CASE WHEN B.memid <>0
THEN F.membercost * B.slots
WHEN B.memid =0
THEN F.guestcost * B.slots
END AS revenue
FROM Bookings AS B
LEFT JOIN Members AS M ON B.memid = M.memid
LEFT JOIN Facilities AS F ON B.facid = F.facid
) AS rev
GROUP BY rev.facilityname
HAVING total_revenue <1000
ORDER BY total_revenue DESC

/*

facilityname	total_revenue	
Pool Table	270.0
Snooker Table	240.0
Table Tennis	180.0

*/

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT R.firstname AS memberfirstname, R.surname AS membersurname, M.firstname AS recommenderfirstname, M.surname AS recommenderlastname
FROM Members AS M
INNER JOIN Members AS R ON M.memid = R.recommendedby
WHERE M.memid <>0
ORDER BY R.surname, R.firstname

/*

memberfirstname	membersurname	recommenderfirstname	recommenderlastname	
Florence	Bader	Ponder	Stibbons
Anne	Baker	Ponder	Stibbons
Timothy	Baker	Jemima	Farrell
Tim	Boothe	Tim	Rownam
Gerald	Butters	Darren	Smith
Joan	Coplin	Timothy	Baker
Erica	Crumpet	Tracy	Smith
Nancy	Dare	Janice	Joplette
Matthew	Genting	Gerald	Butters
John	Hunt	Millicent	Purview
David	Jones	Janice	Joplette
Douglas	Jones	David	Jones
Janice	Joplette	Darren	Smith
Anna	Mackenzie	Darren	Smith
Charles	Owen	Darren	Smith
David	Pinker	Jemima	Farrell
Millicent	Purview	Tracy	Smith
Henrietta	Rumney	Matthew	Genting
Ramnaresh	Sarwin	Florence	Bader
Jack	Smith	Darren	Smith
Ponder	Stibbons	Burton	Tracy
Henry	Worthington-Smyth	Tracy	Smith

*/

/* Q12: Find the facilities with their usage by member, but not guests */

SELECT usi.facilityname, SUM( usi.usa ) AS member_usage_hours, usi.firstname, usi.surname, usi.memid
FROM (

SELECT F.name AS facilityname, M.firstname, M.surname, B.memid,
CASE WHEN B.memid <>0
THEN 30 * B.slots /60
END AS usa
FROM Bookings AS B
LEFT JOIN Members AS M ON B.memid = M.memid
LEFT JOIN Facilities AS F ON B.facid = F.facid
) AS usi
GROUP BY usi.memid
ORDER BY member_usage_hours DESC
LIMIT 29

/*


facilityname	member_usage_hours	firstname	surname	memid	
Table Tennis	342.5000	Darren	Smith	1
Massage Room 1	330.0000	Tim	Rownam	3
Tennis Court 2	220.0000	Tim	Boothe	8
Tennis Court 1	217.5000	Tracy	Smith	2
Tennis Court 1	204.5000	Gerald	Butters	5
Tennis Court 2	183.0000	Burton	Tracy	6
Tennis Court 1	172.5000	Charles	Owen	10
Massage Room 1	163.0000	Janice	Joplette	4
Tennis Court 2	152.5000	David	Jones	11
Tennis Court 1	148.0000	Anne	Baker	12
Tennis Court 2	145.0000	Timothy	Baker	16
Badminton Court	133.5000	Nancy	Dare	7
Tennis Court 2	124.5000	Ponder	Stibbons	9
Badminton Court	118.5000	Florence	Bader	15
Badminton Court	115.5000	Anna	Mackenzie	21
Massage Room 1	109.5000	Jack	Smith	14
Table Tennis	90.0000	Jemima	Farrell	13
Snooker Table	79.5000	David	Pinker	17
Tennis Court 2	76.5000	Ramnaresh	Sarwin	24
Massage Room 2	65.5000	Matthew	Genting	20
Snooker Table	53.0000	Joan	Coplin	22
Badminton Court	30.0000	Henry	Worthington-Smyth	29
Tennis Court 1	25.0000	David	Farrell	28
Tennis Court 1	20.0000	John	Hunt	35
Snooker Table	19.0000	Henrietta	Rumney	27
Badminton Court	18.5000	Douglas	Jones	26
Badminton Court	16.0000	Millicent	Purview	30
Snooker Table	14.0000	Hyacinth	Tupperware	33
Badminton Court	8.5000	Erica	Crumpet	36

*/

/* Q13: Find the facilities usage by month, but not guests */


SELECT usi.facilityname, SUM( usi.usa ) AS member_usage_per_month
FROM (

SELECT F.name AS facilityname,
CASE WHEN B.memid <>0
THEN ( 30 * B.slots /60 ) / ( 24 *30 )
END AS usa
FROM Bookings AS B
LEFT JOIN Members AS M ON B.memid = M.memid
LEFT JOIN Facilities AS F ON B.facid = F.facid
) AS usi
GROUP BY usi.facilityname
ORDER BY member_usage_per_month DESC

/*

facilityname	member_usage_per_month	
Badminton Court	0.75416563
Tennis Court 1	0.66458237
Massage Room 1	0.61388938
Tennis Court 2	0.61249919
Snooker Table	0.59722270
Pool Table	0.59444130
Table Tennis	0.55138933
Squash Court	0.29027801
Massage Room 2	0.03750003

*/