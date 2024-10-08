/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

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
Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT 
    *
FROM `Facilities`
WHERE 
    membercost >0; -- greater than zero means charge a fee




/* Q2: How many facilities do not charge a fee to members? */

SELECT 
    * 
FROM Facilities
WHERE 
    membercost = 0;




/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT 
    facid, 
    name, 
    membercost, 
    monthlymaintenance
FROM `Facilities`
WHERE 
    membercost > 0   -- greater than zero means charge a fee
    AND membercost < monthlymaintenance * 0.2;




/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT 
    *
FROM `Facilities`
WHERE 
    facid IN (1,5);




/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT 
    name,
    monthlymaintenance,
    CASE 
        WHEN monthlymaintenance > 100 THEN 'expensive'
        ELSE 'cheap'
    END AS cost_label -- new column with label
FROM Facilities;




/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT 
    firstname, 
    surname
FROM Members
WHERE 
    joindate = (SELECT MAX(joindate) FROM Members); -- the max join date is the highest num thus more recent




/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

-- only booking has info of which member use which facility 

SELECT DISTINCT
    m.surname,  -- had issue using this code " m.surname || ' ' || m.firstname AS member_name "" as only returns 0, and CONCAT gives an error
    m.firstname
    -- , subq.facid,   -- add these if you want to know which particular Tennis Court
    -- subq.fac_name 
FROM (
    SELECT 
        b.facid,
        b.memid,
        f.name AS fac_name
    FROM Bookings AS b
    LEFT JOIN Facilities AS f
        ON b.facid = f.facid
    WHERE 
        b.facid IN (0,1) -- 0 and 1 fac id represent the 2 tennis courts
) AS subq
LEFT JOIN Members AS m 
    ON subq.memid = m.memid
ORDER BY 
    m.surname, m.firstname; -- ordering by surname and firstname




/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT 
    f.name AS fac_name,
    m.surname, -- still having issue concatenating columns together
    m.firstname,
    CASE 
        WHEN b.memid = 0 -- Check guest cost if memid is 0
            THEN f.guestcost * b.slots  
        ELSE 
            f.membercost * b.slots
    END AS total_cost  -- Calculate total cost
FROM Bookings AS b -- bookings asd both info to connect all 3 tables together
LEFT JOIN Facilities AS f 
    ON b.facid = f.facid
LEFT JOIN Members as m 
    ON b.memid = m.memid 
WHERE 
    b.starttime LIKE '2012-09-14%'
    AND CASE 
        WHEN b.memid = 0   -- Check guest cost if memid is 0
            THEN f.guestcost * b.slots  
        ELSE 
            f.membercost * b.slots
    END >= 30  -- Filter for total costs above $30
ORDER BY 
    total_cost DESC;  -- Sort by total cost from highest to lowest




/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT 
    subq.fac_name,
    subq.surname,
    subq.firstname,
    subq.total_cost
FROM (
    SELECT 
        f.name AS fac_name,
        m.surname,
        m.firstname,
        CASE 
            WHEN b.memid = 0 
                THEN f.guestcost * b.slots
            ELSE
                f.membercost * b.slots
        END AS total_cost  -- Calculate total cost
    FROM Bookings AS b
    LEFT JOIN Facilities AS f 
        ON b.facid = f.facid
    LEFT JOIN Members AS m 
        ON b.memid = m.memid
    WHERE 
        b.starttime LIKE '2012-09-14%'
) AS subq
WHERE 
    subq.total_cost >= 30  -- Filter for total costs above $30
ORDER BY 
    subq.total_cost DESC;  -- Sort by total cost from highest to lowest




/* PART 2: SQLite
We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output. */
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */


SELECT 
    subq.fac_name, -- GROUP BY
    SUM(subq.total_cost) AS total_revenue
FROM (
    -- subq, for each combo of fac_name and user, how much they spend
    SELECT 
        f.name AS fac_name,
        CASE 
            WHEN b.memid = 0 
                THEN f.guestcost * b.slots
            ELSE
                f.membercost * b.slots
        END AS total_cost  -- Calculate total cost
    FROM Bookings AS b
    LEFT JOIN Facilities AS f 
        ON b.facid = f.facid
    LEFT JOIN Members AS m 
        ON b.memid = m.memid    
) AS subq
GROUP BY 
    subq.fac_name
HAVING 
    SUM(subq.total_cost) < 1000
ORDER BY 
    total_revenue DESC;  -- Sort by total cost from highest to lowest




/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT 
    m.surname, 
    m.firstname, 
    m.recommendedby AS recomender_id, 
    recommender.surname AS recomender_surname, 
    recommender.firstname AS recomender_firstname
FROM Members AS m
LEFT JOIN Members AS recommender -- duplicate members table as recommender 
    ON m.recommendedby = recommender.memid
WHERE 
    m.recommendedby != 0
ORDER BY 
    m.surname, m.firstname;




/* Q12: Find the facilities with their usage by member, but not guests */

SELECT
    f.name AS fac_name, -- GROUP By
    subq.facid, -- GROUP By
    COUNT( subq.memid ) AS member_usage
FROM (
    -- subq, return real members and which facility id
    SELECT 
        facid,
        memid
    FROM Bookings
    WHERE memid !=0
) AS subq
LEFT JOIN Facilities AS f 
    USING(facid)
GROUP BY 
    f.name, 
    subq.facid
ORDER BY 
    member_usage DESC;




/* Q13: Find the facilities usage by month, but not guests */

SELECT 
    MONTH( b.starttime ) AS months, -- extract only the month
    f.name AS fac_name,
    COUNT(b.memid) AS fac_usage -- number of member usage
FROM Bookings AS b
LEFT JOIN Facilities AS f -- this is to get the facilities name 
    USING (facid)
WHERE 
    memid !=0
GROUP BY 
    MONTH( b.starttime ), f.name