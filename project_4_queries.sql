--1--
--Retrieve Reservations with Client, Service, Specialist, and Branch Details

SELECT
    r.reservation_id,
    CONCAT(c.first_name, ' ', c.last_name) AS client,
    srv.service_name,
    CONCAT(sp.first_name, ' ', sp.last_name) AS specialist,
    b.branch_name,
    r.reservation_date,
    r.reservation_time,
    r.reservation_status
FROM
    Reservations r
JOIN Clients c ON r.client_id = c.client_id
JOIN Services srv ON r.service_id = srv.service_id
JOIN Specialists sp ON r.specialist_id = sp.specialist_id
JOIN Branches b ON r.branch_id = b.branch_id
ORDER BY r.reservation_date DESC;


--2--
-- Calculate Total Sales per Branch


SELECT
    b.branch_name,
    COUNT(sa.sale_id) AS total_sales,
    SUM(sa.total_amount) AS total_amount,
    SUM(sa.discount_applied) AS total_discounts,
    SUM(sa.final_amount) AS final_amount
FROM
    Sales sa
JOIN Reservations r ON sa.reservation_id = r.reservation_id
JOIN Branches b ON r.branch_id = b.branch_id
GROUP BY b.branch_name
ORDER BY final_amount DESC;

--3--
--Display Client Feedback on Services

SELECT 
    f.feedback_id, 
    CONCAT(c.first_name, ' ', c.last_name) AS client,
    s.service_name, 
    CONCAT(sp.first_name, ' ', sp.last_name) AS specialist, 
    f.rating, 
FROM Feedbacks f
JOIN Clients c ON f.client_id = c.client_id
JOIN Services s ON f.service_id = s.service_id
JOIN Specialists sp ON f.specialist_id = sp.specialist_id;

--4--
--Show Clients with Their Insurance Policies and Claims

SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS client_name,
    ip.policy_name,
    ci.policy_number,
    ci.coverage_percentage,
    ic.claim_id,
    ic.claim_amount,
    ic.claim_status,
    ic.submission_date,
    ic.approval_date
FROM
    Clients c
LEFT JOIN Client_Insurance ci ON c.client_id = ci.client_id AND ci.is_active = TRUE
LEFT JOIN Insurance_Policies ip ON ci.policy_id = ip.policy_id
LEFT JOIN Insurance_Claims ic ON c.client_id = ic.client_id
ORDER BY c.last_name, c.first_name;


--5--
--Find Specialists Available at a Specific Branch on a Given Date

SELECT 
    sp.first_name, 
    sp.last_name, 
    a.availability_date, 
    a.start_time, 
    a.end_time
FROM Specialists sp
JOIN Availability a ON sp.specialist_id = a.specialist_id
JOIN Branches b ON a.branch_id = b.branch_id
WHERE b.branch_name = 'Komitas' 
AND a.availability_date = '2024-06-24';


--6--
--Show the number of reservations made by clients who have an active insurance policy.

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS client_name,
    COUNT(r.reservation_id) AS total_reservations
FROM Reservations r
JOIN Clients c ON r.client_id = c.client_id
JOIN Client_Insurance ci ON c.client_id = ci.client_id
WHERE ci.is_active = TRUE
GROUP BY client_name;

--7--
--Analyze Monthly Sales Trends

SELECT
    TO_CHAR(DATE_TRUNC('month', sa.sale_date), 'YYYY-MM') AS sale_month,
    COUNT(sa.sale_id) AS total_sales,
    SUM(sa.total_amount) AS total_amount,
    SUM(sa.discount_applied) AS total_discounts,
    SUM(sa.final_amount) AS final_amount
FROM
    Sales sa
GROUP BY sale_month
ORDER BY sale_month;

--8--
--Aggregate Service Ratings and Feedback Counts
SELECT
    srv.service_name,
    COUNT(f.feedback_id) AS feedback_count,
    ROUND(AVG(f.rating)::numeric, 2) AS average_rating
FROM
    Services srv
LEFT JOIN Feedbacks f ON srv.service_id = f.service_id
GROUP BY srv.service_name
ORDER BY average_rating DESC NULLS LAST;

--9--
--Retrieve the number of clients per branch, grouped by city.
SELECT 
    ct.city_name, 
    b.branch_name, 
    COUNT(c.client_id) AS total_clients
FROM Clients c
JOIN Branches b ON c.branch_id = b.branch_id
JOIN Cities ct ON b.city_id = ct.city_id
GROUP BY ct.city_name, b.branch_name;


--10--
--Show the total sales amount per service, including discounts applied.

SELECT 
    s.service_name, 
    SUM(sa.final_amount) AS total_sales
FROM Sales sa
JOIN Reservations r ON sa.reservation_id = r.reservation_id
JOIN Services s ON r.service_id = s.service_id
GROUP BY s.service_name;


--11--
--List all services that have been reserved, along with the number of times each service has been reserved.

SELECT 
    s.service_name, 
    COUNT(r.reservation_id) AS reservation_count
FROM Reservations r
JOIN Services s ON r.service_id = s.service_id
GROUP BY s.service_name;

--12--
--Find all active promotions, along with the services they can be applied to.

SELECT 
    p.promotion_name, 
    s.service_name, 
    p.discount_percentage
FROM Promotions p
JOIN Services s ON s.service_id = (
    SELECT r.service_id
    FROM Reservations r
    LIMIT 1
)
WHERE p.is_active = TRUE;

--13--
--Display the total number of reservations and total sales for each branch.

SELECT 
    b.branch_name, 
    COUNT(r.reservation_id) AS total_reservations, 
    SUM(s.final_amount) AS total_sales
FROM Branches b
JOIN Reservations r ON b.branch_id = r.branch_id
JOIN Sales s ON r.reservation_id = s.reservation_id
GROUP BY b.branch_name;


