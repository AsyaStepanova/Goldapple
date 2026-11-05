-- Задание 4.2. 

WITH brand_sales AS (
    SELECT
        p.brand_name_ax AS brand,
        sumIf(s.price, s.date >= addMonths(toStartOfMonth(today()), -1)) AS revenue_last_month,
        sumIf(s.price, s.date < addMonths(toStartOfMonth(today()), -1)) AS revenue_prev_month
    FROM dwh.sales AS s
    JOIN dwh.products AS p 
        ON s.itemid = p.itemid
    WHERE s.date >= addMonths(toStartOfMonth(today()), -2)
      AND s.date < toStartOfMonth(today())
    GROUP BY p.brand_name_ax
)
SELECT
    brand,
    revenue_last_month,
    revenue_prev_month,
    revenue_last_month - revenue_prev_month AS revenue_diff,
    (revenue_last_month - revenue_prev_month) * 100.0
        / nullIf(revenue_prev_month, 0) AS change_percent
FROM brand_sales
WHERE revenue_last_month > 0
ORDER BY revenue_last_month DESC
LIMIT 5;
