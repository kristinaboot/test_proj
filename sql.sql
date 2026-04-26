-- 1. Активность пользователей
SELECT
    u.username,
    r.role,
    COUNT(a.id) AS activity_count
FROM users u
JOIN user_roles r ON u.id = r.user_id
JOIN user_activity a ON u.id = a.user_id
WHERE a.activity_date >= CURRENT_DATE - INTERVAL '1 month'
GROUP BY u.username, r.role
ORDER BY activity_count DESC;

-- 2. Фильтрация транзакций
-- 1 пункт сумма копейка в копейку
SELECT
    t.inn,
    t.credit_num,
    t.doc_id AS tranche_doc,
    t.operation_sum AS tranche_sum,
    tr.doc_id AS transaction_doc,
    tr.operation_sum AS transaction_sum
FROM tranches t
JOIN transactions tr
    ON t.inn::bigint = tr.inn
   AND t.account = tr.account
WHERE t.operation_datetime >= '2024-01-01'
  AND t.operation_datetime < '2025-01-01'
  AND tr.operation_datetime >= t.operation_datetime
  AND tr.operation_datetime <= t.operation_datetime + INTERVAL '10 day'
  AND tr.operation_sum = t.operation_sum;
-- 2 пункт сумма превышает сумму транша
SELECT *
FROM (
    SELECT
        t.inn,
        t.credit_num,
        t.doc_id AS tranche_doc,
        t.operation_sum AS tranche_sum,

        tr.doc_id AS transaction_doc,
        tr.operation_datetime,
        tr.operation_sum AS transaction_sum,

        SUM(tr.operation_sum) OVER (
            PARTITION BY t.doc_id
            ORDER BY tr.operation_datetime
        ) AS running_total

    FROM tranches t
    JOIN transactions tr
        ON t.inn::bigint = tr.inn
       AND t.account = tr.account

    WHERE t.operation_datetime >= '2024-01-01'
      AND t.operation_datetime < '2025-01-01'
      AND tr.operation_datetime >= t.operation_datetime
      AND tr.operation_datetime <= t.operation_datetime + INTERVAL '10 day'
) x
WHERE running_total >= tranche_sum;

-- 3.	Оптимизация SQL запроса
SELECT
    c.client_id,
    c.name,
    c.age,

    COUNT(DISTINCT a.account_id) AS total_accounts,
    COALESCE(SUM(DISTINCT a.balance), 0) AS total_balance,

    SUM(
        CASE
            WHEN t.transaction_type = 'deposit' THEN 1
            ELSE 0
        END
    ) AS total_deposits,

    SUM(
        CASE
            WHEN t.transaction_type = 'withdrawal' THEN 1
            ELSE 0
        END
    ) AS total_withdrawals

FROM clients c
LEFT JOIN accounts a
    ON c.client_id = a.client_id
LEFT JOIN transactions t
    ON a.account_id = t.account_id

WHERE c.registration_date >= '2020-01-01'

GROUP BY
    c.client_id,
    c.name,
    c.age

ORDER BY total_balance DESC;
