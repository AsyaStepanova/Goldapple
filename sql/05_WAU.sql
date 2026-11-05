-- Задание 5. WAU по каждому календарному дню.
-- Считаем уникальных пользователей за текущий день и шесть предыдущих.
-- WAU по дням за всю историю

SELECT DISTINCT
    toDate(timestamp) AS date,
    uniqExact(user_id) OVER (
        ORDER BY toRelativeDayNum(toDate(timestamp))
        RANGE BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS wau
FROM dwh.site_activity
ORDER BY date

