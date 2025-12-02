--#1
SELECT sales_channel, SUM(amount) AS revenue
FROM clinic_sales
WHERE EXTRACT(YEAR FROM datetime) = 2021
GROUP BY sales_channel;

--#2
SELECT uid, SUM(amount) AS total_spent
FROM clinic_sales
WHERE EXTRACT(YEAR FROM datetime) = 2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;

--#3
SELECT EXTRACT(MONTH FROM cs.datetime) AS month,
       SUM(cs.amount) AS revenue,
       (SELECT SUM(e.amount) FROM expenses e WHERE EXTRACT(MONTH FROM e.datetime) = EXTRACT(MONTH FROM cs.datetime) AND EXTRACT(YEAR FROM e.datetime) = 2021) AS expense,
       SUM(cs.amount) - (SELECT SUM(e.amount) FROM expenses e WHERE EXTRACT(MONTH FROM e.datetime) = EXTRACT(MONTH FROM cs.datetime) AND EXTRACT(YEAR FROM e.datetime) = 2021) AS profit,
       CASE WHEN SUM(cs.amount) - (SELECT SUM(e.amount) FROM expenses e WHERE EXTRACT(MONTH FROM e.datetime) = EXTRACT(MONTH FROM cs.datetime) AND EXTRACT(YEAR FROM e.datetime) = 2021) > 0
            THEN 'Profitable' ELSE 'Not-Profitable' END AS status
FROM clinic_sales cs
WHERE EXTRACT(YEAR FROM cs.datetime) = 2021
GROUP BY EXTRACT(MONTH FROM cs.datetime);

--#4
WITH clinic_profit AS (
    SELECT c.city,
           EXTRACT(MONTH FROM cs.datetime) AS month,
           cs.cid,
           SUM(cs.amount) - COALESCE((SELECT SUM(e.amount) FROM expenses e WHERE e.cid = cs.cid AND EXTRACT(MONTH FROM e.datetime) = EXTRACT(MONTH FROM cs.datetime) AND EXTRACT(YEAR FROM e.datetime) = 2021),0) AS profit
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    WHERE EXTRACT(YEAR FROM cs.datetime) = 2021
    GROUP BY c.city, EXTRACT(MONTH FROM cs.datetime), cs.cid
)
SELECT city, month, cid, profit
FROM (
    SELECT city, month, cid, profit,
           RANK() OVER (PARTITION BY city, month ORDER BY profit DESC) AS rnk
    FROM clinic_profit
) ranked
WHERE rnk = 1;

--#5
WITH clinic_profit AS (
    SELECT c.state,
           EXTRACT(MONTH FROM cs.datetime) AS month,
           cs.cid,
           SUM(cs.amount) - COALESCE((SELECT SUM(e.amount) FROM expenses e WHERE e.cid = cs.cid AND EXTRACT(MONTH FROM e.datetime) = EXTRACT(MONTH FROM cs.datetime) AND EXTRACT(YEAR FROM e.datetime) = 2021),0) AS profit
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    WHERE EXTRACT(YEAR FROM cs.datetime) = 2021
    GROUP BY c.state, EXTRACT(MONTH FROM cs.datetime), cs.cid
)
SELECT state, month, cid, profit
FROM (
    SELECT state, month, cid, profit,
           DENSE_RANK() OVER (PARTITION BY state, month ORDER BY profit ASC) AS rnk
    FROM clinic_profit
) ranked
WHERE rnk = 2;
