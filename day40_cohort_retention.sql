-- Day 40: 코호트 분석과 월별 리텐션
-- 목표: 고객을 첫 구매월(코호트)로 묶고, 이후 몇 개월 차에 다시 구매했는지 리텐션을 계산한다.

-- 개념 설명
--   코호트      : 같은 시점(예: 첫 구매월)에 시작한 고객 집단
--   월 차이     : (주문 연도*12 + 주문 월) - (코호트 연도*12 + 코호트 월)  -> 0이면 첫 구매월, 1이면 다음 달
--   리텐션      : 코호트 중 N개월 차에 다시 구매한 고객 수 / 코호트 전체 고객 수 * 100
--   주의: 한 고객이 같은 달에 여러 번 주문할 수 있으므로 COUNT(DISTINCT customer_id) 로 센다.
--   날짜 함수 대신 SUBSTR + CAST 만 사용해 SQLite, MySQL 모두에서 동작한다.
--   (CTE 와 윈도우 함수는 MySQL 8.0 / SQLite 3.25 이상)

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    id          INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date  VARCHAR(10) NOT NULL
);

INSERT INTO orders (id, customer_id, order_date) VALUES
    (1, 101, '2026-01-05'), (2, 102, '2026-01-10'), (3, 103, '2026-01-20'),
    (4, 101, '2026-02-03'), (5, 104, '2026-02-14'), (6, 105, '2026-02-20'),
    (7, 102, '2026-03-01'), (8, 101, '2026-03-15'), (9, 104, '2026-03-20'),
    (10, 106, '2026-03-22'), (11, 103, '2026-03-25'), (12, 101, '2026-03-28'),
    (13, 106, '2026-04-02'), (14, 105, '2026-04-10');

-- 1) 고객별 코호트(첫 구매월)
SELECT customer_id,
       SUBSTR(MIN(order_date), 1, 7) AS cohort_month
FROM orders
GROUP BY customer_id
ORDER BY customer_id;

-- 2) 코호트별 고객 수
SELECT cohort_month, COUNT(*) AS cohort_size
FROM (
    SELECT customer_id, SUBSTR(MIN(order_date), 1, 7) AS cohort_month
    FROM orders
    GROUP BY customer_id
) c
GROUP BY cohort_month
ORDER BY cohort_month;

-- 3) 코호트 x 경과 개월별 활동 고객 수
WITH cohort AS (
    SELECT customer_id, SUBSTR(MIN(order_date), 1, 7) AS cohort_month
    FROM orders
    GROUP BY customer_id
),
activity AS (
    SELECT c.cohort_month,
           o.customer_id,
           (CAST(SUBSTR(o.order_date, 1, 4) AS INTEGER) * 12 + CAST(SUBSTR(o.order_date, 6, 2) AS INTEGER))
         - (CAST(SUBSTR(c.cohort_month, 1, 4) AS INTEGER) * 12 + CAST(SUBSTR(c.cohort_month, 6, 2) AS INTEGER))
           AS month_diff
    FROM orders o
    JOIN cohort c ON c.customer_id = o.customer_id
)
SELECT cohort_month, month_diff,
       COUNT(DISTINCT customer_id) AS active_customers
FROM activity
GROUP BY cohort_month, month_diff
ORDER BY cohort_month, month_diff;

-- 4) 리텐션율(%): 활동 고객 수 / 코호트 크기 (month_diff = 0 은 항상 100)
WITH cohort AS (
    SELECT customer_id, SUBSTR(MIN(order_date), 1, 7) AS cohort_month
    FROM orders
    GROUP BY customer_id
),
activity AS (
    SELECT c.cohort_month,
           o.customer_id,
           (CAST(SUBSTR(o.order_date, 1, 4) AS INTEGER) * 12 + CAST(SUBSTR(o.order_date, 6, 2) AS INTEGER))
         - (CAST(SUBSTR(c.cohort_month, 1, 4) AS INTEGER) * 12 + CAST(SUBSTR(c.cohort_month, 6, 2) AS INTEGER))
           AS month_diff
    FROM orders o
    JOIN cohort c ON c.customer_id = o.customer_id
),
size AS (
    SELECT cohort_month, COUNT(*) AS cohort_size
    FROM cohort
    GROUP BY cohort_month
)
SELECT a.cohort_month, a.month_diff,
       COUNT(DISTINCT a.customer_id) AS active_customers,
       s.cohort_size,
       ROUND(100.0 * COUNT(DISTINCT a.customer_id) / s.cohort_size, 1) AS retention_pct
FROM activity a
JOIN size s ON s.cohort_month = a.cohort_month
GROUP BY a.cohort_month, a.month_diff, s.cohort_size
ORDER BY a.cohort_month, a.month_diff;

-- 연습 문제
-- 1) 코호트별로 1개월 차(month_diff = 1)에 다시 구매한 고객 수와 비율만 조회해 보세요.
-- 2) 첫 구매월과 같은 달에 2번 이상 주문한 고객의 customer_id 를 찾아보세요. (힌트: GROUP BY + HAVING)
