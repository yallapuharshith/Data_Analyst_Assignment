--#1
SELECT u.user_id, b.room_no
FROM users u
JOIN bookings b ON u.user_id = b.user_id
WHERE b.booking_date = (
    SELECT MAX(b2.booking_date)
    FROM bookings b2
    WHERE b2.user_id = u.user_id
); 

--#2
SELECT bc.booking_id,
       SUM(i.item_rate * bc.item_quantity) AS total_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
JOIN bookings b ON bc.booking_id = b.booking_id
WHERE EXTRACT(MONTH FROM b.booking_date) = 11
  AND EXTRACT(YEAR FROM b.booking_date) = 2021
GROUP BY bc.booking_id;

--#3
SELECT bc.bill_id,
       SUM(i.item_rate * bc.item_quantity) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE EXTRACT(MONTH FROM bc.bill_date) = 10
  AND EXTRACT(YEAR FROM bc.bill_date) = 2021
GROUP BY bc.bill_id
HAVING SUM(i.item_rate * bc.item_quantity) > 1000;

--#4
WITH monthly_orders AS (
    SELECT EXTRACT(MONTH FROM bc.bill_date) AS month,
           bc.item_id,
           SUM(bc.item_quantity) AS total_qty
    FROM booking_commercials bc
    WHERE EXTRACT(YEAR FROM bc.bill_date) = 2021
    GROUP BY EXTRACT(MONTH FROM bc.bill_date), bc.item_id
)
SELECT month,
       (SELECT item_id FROM monthly_orders mo WHERE mo.month = m.month ORDER BY total_qty DESC LIMIT 1) AS most_ordered_item,
       (SELECT item_id FROM monthly_orders mo WHERE mo.month = m.month ORDER BY total_qty ASC LIMIT 1) AS least_ordered_item
FROM (SELECT DISTINCT month FROM monthly_orders) m;

--#5
WITH monthly_bills AS (
    SELECT EXTRACT(MONTH FROM bc.bill_date) AS month,
           b.user_id,
           SUM(i.item_rate * bc.item_quantity) AS bill_value
    FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
    JOIN bookings b ON bc.booking_id = b.booking_id
    WHERE EXTRACT(YEAR FROM bc.bill_date) = 2021
    GROUP BY EXTRACT(MONTH FROM bc.bill_date), b.user_id
),
ranked AS (
    SELECT month, user_id, bill_value,
           DENSE_RANK() OVER (PARTITION BY month ORDER BY bill_value DESC) AS rnk
    FROM monthly_bills
)
SELECT month, user_id, bill_value
FROM ranked
WHERE rnk = 2;

