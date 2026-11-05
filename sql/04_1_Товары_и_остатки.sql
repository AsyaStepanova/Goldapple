
WITH sales AS (
    SELECT
        itemid,
        sumIf(qty, date >= addMonths(toStartOfMonth(today()), -1)) AS qty_last_month,
        sumIf(price, date >= addMonths(toStartOfMonth(today()), -1)) AS revenue_last_month, -- при условии, что price - это сумма за QTY
        sum(qty) /   
        (2 +
        dateDiff('day', toStartOfMonth(today()), today() + 1) 
        /
        dateDiff('day', toStartOfMonth(today()), toLastDayOfMonth(today()) + 1) AS avg_qty_three_months --рассчитала,  как: среднемесячный объем,  с учетом последнего месяца,  формула высчитывает долю прошедших дней текущего месяца 
---------------------------------------------------------------------------
    -- если прайс цена за единицу айтема 
    -- sumIf(qty * price, date >= last_month) AS revenue_last_month,
   -- ,avgIf(price, date >= addMonths(toStartOfMonth(today()), -1)) AS avg_price_last_month
    FROM dwh.sales
    WHERE date >= addMonths(toStartOfMonth(today()), -3)
      AND date < toStartOfMonth(today())
    GROUP BY itemid
),
stocks AS (
    SELECT
        itemid,
        argMax(qty, date) AS current_stock
    FROM dwh.stock
    GROUP BY itemid
)
SELECT
    p.itemid,
    p.name_ax,
    p.brand_name_ax,
    p.category,
    s.qty_last_month,
    s.revenue_last_month,
    s.revenue_last_month / nullIf(s.qty_last_month, 0) AS avg_price_last_month,--средняя цена на товар при условии, что price - это сумма за QTY
    s.avg_qty_three_months,
    st.current_stock - s.avg_qty_three_months AS stock_minus_avg_sales
    ------ avg_price_last_month при условии,  что price -  цена за айтем 
FROM sales AS s
     JOIN dwh.products AS p 
            ON s.itemid = p.itemid
     LEFT JOIN stocks AS st 
            ON s.itemid = st.itemid
WHERE s.qty_last_month > 0
ORDER BY s.revenue_last_month DESC;
