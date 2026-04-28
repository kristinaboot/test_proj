-- 1. Активность пользователей

CREATE TABLE users
(
    id integer primary key,
    username varchar not null,
    created_at date not null
);

CREATE TABLE user_activity
(
    id integer primary key,
    user_id integer not null,
    activity_type_id integer not null,
    activity_date date not null,
    foreign key (user_id) references users(id)
);

CREATE TABLE activity_types
(
    id integer primary key,
    name varchar not null
);

CREATE TABLE user_roles
(
    id integer primary key,
    user_id integer not null,
    role varchar not null,
    assigned_at date not null,
    foreign key (user_id) references users(id)
);

INSERT INTO users (id, username, created_at) VALUES
    (1, 'user1', '2024-01-01'),
    (2, 'user2', '2024-02-15'),
    (3, 'user3', '2024-03-10'),
    (4, 'user4', '2024-04-01'),
    (5, 'user5', '2024-05-01'),
    (6, 'user6', '2024-06-01');

INSERT INTO activity_types (id, name) VALUES
    (1, 'login'),
    (2, 'logout'),
    (3, 'purchase');

INSERT INTO user_activity (id, user_id, activity_type_id, activity_date) VALUES
    (1, 1, 1, '2024-10-01'),
    (2, 1, 2, '2024-10-05'),
    (3, 1, 1, '2024-10-10'),
    (4, 2, 1, '2024-10-15'),
    (5, 2, 3, '2024-09-20'),
    (6, 3, 1, '2024-08-25'),
    (7, 4, 1, '2024-10-22'),
    (8, 4, 2, '2024-10-25'),
    (9, 6, 1, '2024-10-05'),
    (10, 6, 3, '2024-10-10'),
    (11, 6, 1, '2024-09-30');

INSERT INTO user_roles (id, user_id, role, assigned_at) VALUES
    (1, 1, 'admin', '2024-10-01'),
    (2, 1, 'moderator', '2024-10-05'),
    (3, 2, 'user', '2024-10-10'),
    (4, 4, 'guest', '2024-10-20'),
    (5, 6, 'editor', '2024-10-15');

-- для теста беру октябрь как последний месяц
SELECT
    u.username,
    r.role,
    COUNT(a.id) AS activity_count
FROM users u
JOIN user_roles r ON u.id = r.user_id
JOIN user_activity a ON u.id = a.user_id
WHERE a.activity_date >= DATE '2024-10-01' -- WHERE a.activity_date >= CURRENT_DATE - INTERVAL '1 month'
  AND a.activity_date < DATE '2024-11-01'
GROUP BY u.username, r.role
ORDER BY activity_count DESC;
-- вывод: activity_count по каждому юзер - роль
-- username |   role    | activity_count
------------+-----------+----------------
-- user1    | admin     |              3
-- user1    | moderator |              3
-- user4    | guest     |              2
-- user6    | editor    |              2
-- user2    | user      |              1

-- 2. Фильтрация транзакций

CREATE TABLE tranches
(
    inn text,
    credit_num text,
    account text,
    operation_datetime timestamp,
    operation_sum numeric,
    doc_id numeric
);

CREATE TABLE transactions
(
    inn int8,
    account text,
    operation_datetime timestamp,
    operation_sum numeric,
    ctrg_inn int8,
    ctrg_account text,
    doc_id text
);

INSERT INTO tranches (inn, credit_num, account, operation_datetime, operation_sum, doc_id) VALUES
    ('1234567890', 'CREDIT001', '40817810000000000001', '2024-01-01 10:00:00', 1000.00, 1),
    ('1234567890', 'CREDIT002', '40817810000000000002', '2024-01-05 12:00:00', 1500.00, 2),
    ('1234567890', 'CREDIT003', '40817810000000000003', '2024-01-10 14:00:00', 2000.00, 3),
    ('2345678901', 'CREDIT004', '40817810000000000004', '2024-02-15 09:30:00', 3000.00, 4),
    ('3456789012', 'CREDIT005', '40817810000000000005', '2024-03-20 16:45:00', 5000.00, 5),
    ('4567890123', 'CREDIT006', '40817810000000000006', '2024-04-25 11:15:00', 7500.00, 6),
    ('5678901234', 'CREDIT007', '40817810000000000007', '2024-05-30 14:20:00', 10000.00, 7),
    ('6789012345', 'CREDIT008', '40817810000000000008', '2024-06-10 13:00:00', 12500.00, 8),
    ('7890123456', 'CREDIT009', '40817810000000000009', '2024-07-15 10:45:00', 15000.00, 9),
    ('8901234567', 'CREDIT010', '40817810000000000010', '2024-08-20 15:30:00', 20000.00, 10);

INSERT INTO transactions (inn, account, operation_datetime, operation_sum, ctrg_inn, ctrg_account, doc_id) VALUES
    (1234567890, '40817810000000000001', '2024-01-02 10:10:00', 900.00, 9876543210, '40817810000000000014', 'T1'),
    (2345678901, '40817810000000000004', '2024-02-17 11:20:00', 3500.00, 8765432109, '40817810000000000015', 'T2'),
    (1234567890, '40817810000000000003', '2024-01-15 14:05:00', 2500.00, 9876543210, '40817810000000000006', 'T3'),
    (2345678901, '40817810000000000004', '2024-02-16 10:10:00', 3200.00, 8765432109, '40817810000000000007', 'T4'),
    (7890123456, '40817810000000000009', '2024-07-18 10:15:00', 16000.00, 3210987654, '40817810000000000012', 'T5'),
    (1234567890, '40817810000000000002', '2024-01-06 12:05:00', 1500.00, 9876543210, '40817810000000000005', 'T6'),
    (5678901234, '40817810000000000007', '2024-06-01 14:40:00', 11000.00, 5432109876, '40817810000000000010', 'T7'),
    (6789012345, '40817810000000000008', '2024-06-12 13:50:00', 13000.00, 4321098765, '40817810000000000011', 'T8'),
    (3456789012, '40817810000000000005', '2024-03-22 15:20:00', 5500.00, 7654321098, '40817810000000000008', 'T9'),
    (8901234567, '40817810000000000010', '2024-08-22 15:25:00', 15000.00, 2109876543, '40817810000000000013', 'T10'),
    (1234567890, '40817810000000000001', '2024-01-01 10:05:00', 1000.00, 9876543210, '40817810000000000004', 'T11'),
    (4567890123, '40817810000000000006', '2024-04-27 11:30:00', 8000.00, 6543210987, '40817810000000000009', 'T12'),
    (8901234567, '40817810000000000010', '2024-08-25 16:30:00', 5800.00, 7654321098, '40817810000000000016', 'T13');

-- 1 пункт сумма копейка в копейку
SELECT
    t.inn,
    t.credit_num,
    t.doc_id AS tranche_doc,
    t.operation_sum AS tranche_sum,
    tr.doc_id AS transaction_doc,
    tr.operation_datetime AS transaction_datetime,
    tr.operation_sum AS transaction_sum,
    tr.ctrg_inn,
    tr.ctrg_account,
    'exact_match' AS match_type
FROM tranches t
JOIN transactions tr
    ON t.inn::bigint = tr.inn
   AND t.account = tr.account
WHERE t.operation_datetime >= '2024-01-01'
  AND t.operation_datetime < '2025-01-01'
  AND tr.operation_datetime >= t.operation_datetime
  AND tr.operation_datetime <= t.operation_datetime + INTERVAL '10 day'
  AND tr.operation_sum = t.operation_sum
ORDER BY t.doc_id, tr.operation_datetime;
-- вывод
--    inn     | credit_num | tranche_doc | tranche_sum | transaction_doc | transaction_datetime | transaction_sum |  ctrg_inn  |     ctrg_account     | match_type
--------------+------------+-------------+-------------+-----------------+----------------------+-----------------+------------+----------------------+-------------
-- 1234567890 | CREDIT001  |           1 |     1000.00 | T11             | 2024-01-01 10:05:00  |         1000.00 | 9876543210 | 40817810000000000004 | exact_match
-- 1234567890 | CREDIT002  |           2 |     1500.00 | T6              | 2024-01-06 12:05:00  |         1500.00 | 9876543210 | 40817810000000000005 | exact_match

-- 2 пункт сумма превышает сумму транша
WITH base AS (
    SELECT
        t.inn,
        t.credit_num,
        t.doc_id AS tranche_doc,
        t.operation_datetime AS tranche_datetime,
        t.operation_sum AS tranche_sum,
        tr.doc_id AS transaction_doc,
        tr.operation_datetime AS transaction_datetime,
        tr.operation_sum AS transaction_sum,
        tr.ctrg_inn,
        tr.ctrg_account
    FROM tranches t
    JOIN transactions tr
        ON t.inn::bigint = tr.inn
       AND t.account = tr.account
    WHERE t.operation_datetime >= '2024-01-01'
      AND t.operation_datetime < '2025-01-01'
      AND tr.operation_datetime >= t.operation_datetime
      AND tr.operation_datetime <= t.operation_datetime + INTERVAL '10 day'
),
exact_tranches AS (
    SELECT DISTINCT tranche_doc
    FROM base
    WHERE transaction_sum = tranche_sum
),
running AS (
    SELECT
        b.*,
        SUM(transaction_sum) OVER (
            PARTITION BY tranche_doc
            ORDER BY transaction_datetime, transaction_doc
        ) AS running_total
    FROM base b
    WHERE NOT EXISTS (
        SELECT 1
        FROM exact_tranches e
        WHERE e.tranche_doc = b.tranche_doc
    )
),
first_exceed AS (
    SELECT
        tranche_doc,
        MIN(transaction_datetime) AS first_exceed_datetime
    FROM running
    WHERE running_total > tranche_sum
    GROUP BY tranche_doc
)
SELECT
    r.inn,
    r.credit_num,
    r.tranche_doc,
    r.tranche_sum,
    r.transaction_doc,
    r.transaction_datetime,
    r.transaction_sum,
    r.running_total,
    r.ctrg_inn,
    r.ctrg_account,
    'cumulative_exceed' AS match_type
FROM running r
JOIN first_exceed fe
    ON r.tranche_doc = fe.tranche_doc
WHERE r.transaction_datetime <= fe.first_exceed_datetime
ORDER BY r.tranche_doc, r.transaction_datetime;
-- вывод
--    inn     | credit_num | tranche_doc | tranche_sum | transaction_doc | transaction_datetime | transaction_sum | running_total |  ctrg_inn  |     ctrg_account     |    match_type
--------------+------------+-------------+-------------+-----------------+----------------------+-----------------+---------------+------------+----------------------+-------------------
-- 1234567890 | CREDIT003  |           3 |     2000.00 | T3              | 2024-01-15 14:05:00  |         2500.00 |       2500.00 | 9876543210 | 40817810000000000006 | cumulative_exceed
-- 2345678901 | CREDIT004  |           4 |     3000.00 | T4              | 2024-02-16 10:10:00  |         3200.00 |       3200.00 | 8765432109 | 40817810000000000007 | cumulative_exceed
-- 3456789012 | CREDIT005  |           5 |     5000.00 | T9              | 2024-03-22 15:20:00  |         5500.00 |       5500.00 | 7654321098 | 40817810000000000008 | cumulative_exceed
-- 4567890123 | CREDIT006  |           6 |     7500.00 | T12             | 2024-04-27 11:30:00  |         8000.00 |       8000.00 | 6543210987 | 40817810000000000009 | cumulative_exceed
-- 5678901234 | CREDIT007  |           7 |    10000.00 | T7              | 2024-06-01 14:40:00  |        11000.00 |      11000.00 | 5432109876 | 40817810000000000010 | cumulative_exceed
-- 6789012345 | CREDIT008  |           8 |    12500.00 | T8              | 2024-06-12 13:50:00  |        13000.00 |      13000.00 | 4321098765 | 40817810000000000011 | cumulative_exceed
-- 7890123456 | CREDIT009  |           9 |    15000.00 | T5              | 2024-07-18 10:15:00  |        16000.00 |      16000.00 | 3210987654 | 40817810000000000012 | cumulative_exceed
-- 8901234567 | CREDIT010  |          10 |    20000.00 | T10             | 2024-08-22 15:25:00  |        15000.00 |      15000.00 | 2109876543 | 40817810000000000013 | cumulative_exceed
-- 8901234567 | CREDIT010  |          10 |    20000.00 | T13             | 2024-08-25 16:30:00  |         5800.00 |      20800.00 | 7654321098 | 40817810000000000016 | cumulative_exceed

-- 3.	Оптимизация SQL запроса
CREATE TABLE clients
(
    client_id serial primary key,
    name varchar(100) not null,
    age integer check (age >= 0),
    registration_date date not null
);

CREATE TABLE accounts
(
    account_id serial primary key,
    client_id integer references clients(client_id) on delete cascade,
    balance decimal(15, 2) not null check (balance >= 0),
    open_date date not null
);

CREATE TABLE transactions
(
    transaction_id serial primary key,
    account_id integer references accounts(account_id) on delete cascade,
    amount decimal(15, 2) not null,
    transaction_date date not null,
    transaction_type varchar(50) not null check (transaction_type in ('deposit', 'withdrawal'))
);

INSERT INTO clients (name, age, registration_date) VALUES
    ('Иван Иванов', 30, '2019-05-15'),
    ('Мария Петрова', 25, '2020-01-10'),
    ('Алексей Сидоров', 40, '2021-03-22'),
    ('Елена Кузнецова', 35, '2020-07-19'),
    ('Дмитрий Смирнов', 28, '2022-11-05'),
    ('Ольга Васнецова', 50, '2018-12-30'),
    ('Сергей Козлов', 33, '2020-06-14'),
    ('Анна Морозова', 29, '2021-09-01'),
    ('Павел Новиков', 45, '2019-08-25'),
    ('Татьяна Павлова', 31, '2020-04-17');

INSERT INTO accounts (client_id, balance, open_date) VALUES
    (1, 15000.00, '2019-05-20'),
    (1, 5000.00, '2020-02-10'),
    (2, 20000.00, '2020-01-15'),
    (3, 30000.00, '2021-03-25'),
    (4, 10000.00, '2020-07-25'),
    (5, 25000.00, '2022-11-10'),
    (6, 40000.00, '2019-01-05'),
    (7, 12000.00, '2020-06-20'),
    (8, 18000.00, '2021-09-05'),
    (9, 22000.00, '2019-09-01'),
    (10, 15000.00, '2020-04-20');

INSERT INTO transactions (account_id, amount, transaction_date, transaction_type) VALUES
    (1, 1000.00, '2023-01-05', 'deposit'),
    (1, 500.00, '2023-01-10', 'withdrawal'),
    (2, 2000.00, '2023-02-15', 'deposit'),
    (2, 1000.00, '2023-02-20', 'withdrawal'),
    (3, 3000.00, '2023-03-25', 'deposit'),
    (3, 1500.00, '2023-03-30', 'withdrawal'),
    (4, 4000.00, '2023-04-05', 'deposit'),
    (4, 2000.00, '2023-04-10', 'withdrawal'),
    (5, 5000.00, '2023-05-15', 'deposit'),
    (5, 2500.00, '2023-05-20', 'withdrawal'),
    (6, 6000.00, '2023-06-25', 'deposit'),
    (6, 3000.00, '2023-06-30', 'withdrawal'),
    (7, 7000.00, '2023-07-05', 'deposit'),
    (7, 3500.00, '2023-07-10', 'withdrawal'),
    (8, 8000.00, '2023-08-15', 'deposit'),
    (8, 4000.00, '2023-08-20', 'withdrawal'),
    (9, 9000.00, '2023-09-25', 'deposit'),
    (9, 4500.00, '2023-09-30', 'withdrawal'),
    (10, 10000.00, '2023-10-05', 'deposit'),
    (10, 5000.00, '2023-10-10', 'withdrawal');


-- было
--select c.client_id, c.name, c.age,
--(select count(*) from accounts a where a.client_id = c.client_id) as total_accounts,
--(select sum(a.balance) from accounts a where a.client_id = c.client_id) as total_balance,
--(select count(*) from transactions t join accounts a on t.account_id = a.account_id where a.client_id = c.client_id and t.transaction_type = 'deposit') as total_deposits,
--(select count(*) from transactions t join accounts a on t.account_id = a.account_id where a.client_id = c.client_id and t.transaction_type = 'withdrawal') as total_withdrawals
--from clients c where c.registration_date >= '2020-01-01' order by total_balance desc;

-- Описание оптимизации:
-- В исходном запросе для каждого клиента выполнялись подзапросы
-- Они заменены на предварительные агрегации по счетам и транзакциям
-- Это уменьшает количество повторных обращений к таблицам accounts и transactions
-- Баланс считается отдельно от транзакций, чтобы JOIN с transactions не умножал суммы балансов

WITH accounts_agg AS (
    SELECT
        client_id,
        COUNT(*) AS total_accounts,
        SUM(balance) AS total_balance
    FROM accounts
    GROUP BY client_id
),
transactions_agg AS (
    SELECT
        a.client_id,
        COUNT(*) FILTER (WHERE t.transaction_type = 'deposit') AS total_deposits,
        COUNT(*) FILTER (WHERE t.transaction_type = 'withdrawal') AS total_withdrawals
    FROM accounts a
    LEFT JOIN transactions t
        ON a.account_id = t.account_id
    GROUP BY a.client_id
)
SELECT
    c.client_id,
    c.name,
    c.age,
    COALESCE(aa.total_accounts, 0) AS total_accounts,
    COALESCE(aa.total_balance, 0) AS total_balance,
    COALESCE(ta.total_deposits, 0) AS total_deposits,
    COALESCE(ta.total_withdrawals, 0) AS total_withdrawals
FROM clients c
LEFT JOIN accounts_agg aa
    ON c.client_id = aa.client_id
LEFT JOIN transactions_agg ta
    ON c.client_id = ta.client_id
WHERE c.registration_date >= '2020-01-01'
ORDER BY total_balance DESC;
-- вывод
-- client_id |      name       | age | total_accounts | total_balance | total_deposits | total_withdrawals
-------------+-----------------+-----+----------------+---------------+----------------+-------------------
--         3 | Алексей Сидоров |  40 |              1 |      30000.00 |              1 |                 1
--         5 | Дмитрий Смирнов |  28 |              1 |      25000.00 |              1 |                 1
--         2 | Мария Петрова   |  25 |              1 |      20000.00 |              1 |                 1
--         8 | Анна Морозова   |  29 |              1 |      18000.00 |              1 |                 1
--        10 | Татьяна Павлова |  31 |              1 |      15000.00 |              0 |                 0
--         7 | Сергей Козлов   |  33 |              1 |      12000.00 |              1 |                 1
--         4 | Елена Кузнецова |  35 |              1 |      10000.00 |              1 |                 1
