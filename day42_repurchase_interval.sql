-- Day 42: 재구매 주기 분석
-- 목표: LAG 로 이전 주문일을 가져와 고객별 주문 간격(일)을 구하고, 평균 재구매 주기와 이탈 위험 고객을 찾는다.

-- 개념 설명
--   LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)
--       : 같은 고객의 바로 이전 주문일. 첫 주문은 NULL 이다.
--   주문 간격(일) = 이번 주문일 - 이전 주문일
--   날짜 차이는 YYYY-MM-DD 를 연*372 + 월*31 + 일 로 환산한 근사 일수로 계산해
--   SQLite, MySQL 모두에서 동작하게 한다. (윈도우 함수와 CTE 는 MySQL 8.0 / SQLite 3.25 이상)
--   AVG 는 NULL 을 무시하므로 첫 주문(간격 NULL)은 평균에서 자동으로 빠진다.

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    id          INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date  VARCHAR(10) NOT NULL,
    amount      INTEGER NOT NULL
);

INSERT INTO orders (id, customer_id, order_date, amount) VALUES
    (1, 101, '2026-01-05', 30000), (2, 101, '2026-02-03', 45000), (3, 101, '2026-03-05', 60000), (4, 101, '2026-04-04', 50000),
    (5, 102, '2026-01-10', 20000), (6, 102, '2026-03-01', 15000),
    (7, 103, '2026-01-20', 80000),
    (8, 104, '2026-03-20', 35000), (9, 104, '2026-04-03', 40000), (10, 104, '2026-04-17', 25000),
    (11, 105, '2026-02-20', 10000), (12, 105, '2026-02-25', 12000);

-- 1) 이전 주문일 붙이기
SELECT customer_id, order_date,
       LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_date
FROM orders
ORDER BY customer_id, order_date;

-- 2) 주문 간격(일) 계산 (첫 주문은 NULL)
WITH gaps AS (
    SELECT customer_id, order_date,
           LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_date
    FROM orders
)
SELECT customer_id, order_date, prev_date,
       (CAST(SUBSTR(order_date, 1, 4) AS INTEGER) * 372 + CAST(SUBSTR(order_date, 6, 2) AS INTEGER) * 31 + CAST(SUBSTR(order_date, 9, 2) AS INTEGER))
     - (CAST(SUBSTR(prev_date, 1, 4) AS INTEGER) * 372 + CAST(SUBSTR(prev_date, 6, 2) AS INTEGER) * 31 + CAST(SUBSTR(prev_date, 9, 2) AS INTEGER))
       AS gap_days
FROM gaps
ORDER BY customer_id, order_date;

-- 3) 고객별 평균 재구매 주기 (2회 이상 구매한 고객만 값이 생김)
WITH gaps AS (
    SELECT customer_id, order_date,
           LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_date
    FROM orders
),
gap_days AS (
    SELECT customer_id,
           (CAST(SUBSTR(order_date, 1, 4) AS INTEGER) * 372 + CAST(SUBSTR(order_date, 6, 2) AS INTEGER) * 31 + CAST(SUBSTR(order_date, 9, 2) AS INTEGER))
         - (CAST(SUBSTR(prev_date, 1, 4) AS INTEGER) * 372 + CAST(SUBSTR(prev_date, 6, 2) AS INTEGER) * 31 + CAST(SUBSTR(prev_date, 9, 2) AS INTEGER))
           AS gap
    FROM gaps
    WHERE prev_date IS NOT NULL
)
SELECT customer_id,
       COUNT(*)           AS repurchase_cnt,
       ROUND(AVG(gap), 1) AS avg_gap_days,
       MIN(gap)           AS min_gap,
       MAX(gap)           AS max_gap
FROM gap_days
GROUP BY customer_id
ORDER BY customer_id;

-- 4) 이탈 위험 고객: 기준일('2026-05-31') 기준 마지막 주문 후 경과일이 평균 재구매 주기의 2배를 넘으면 '위험'
WITH gaps AS (
    SELECT customer_id, order_date,
           LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_date
    FROM orders
),
avg_gap AS (
    SELECT customer_id,
           AVG((CAST(SUBSTR(order_date, 1, 4) AS INTEGER) * 372 + CAST(SUBSTR(order_date, 6, 2) AS INTEGER) * 31 + CAST(SUBSTR(order_date, 9, 2) AS INTEGER))
             - (CAST(SUBSTR(prev_date, 1, 4) AS INTEGER) * 372 + CAST(SUBSTR(prev_date, 6, 2) AS INTEGER) * 31 + CAST(SUBSTR(prev_date, 9, 2) AS INTEGER))) AS avg_gap
    FROM gaps
    WHERE prev_date IS NOT NULL
    GROUP BY customer_id
),
last_order AS (
    SELECT customer_id, MAX(order_date) AS last_date
    FROM orders
    GROUP BY customer_id
)
SELECT l.customer_id, l.last_date,
       (CAST(SUBSTR('2026-05-31', 1, 4) AS INTEGER) * 372 + CAST(SUBSTR('2026-05-31', 6, 2) AS INTEGER) * 31 + CAST(SUBSTR('2026-05-31', 9, 2) AS INTEGER))
     - (CAST(SUBSTR(l.last_date, 1, 4) AS INTEGER) * 372 + CAST(SUBSTR(l.last_date, 6, 2) AS INTEGER) * 31 + CAST(SUBSTR(l.last_date, 9, 2) AS INTEGER))
       AS days_since_last,
       ROUND(a.avg_gap, 1) AS avg_gap,
       CASE
           WHEN a.avg_gap IS NULL THEN '1회 구매'
           WHEN (CAST(SUBSTR('2026-05-31', 1, 4) AS INTEGER) * 372 + CAST(SUBSTR('2026-05-31', 6, 2) AS INTEGER) * 31 + CAST(SUBSTR('2026-05-31', 9, 2) AS INTEGER))
              - (CAST(SUBSTR(l.last_date, 1, 4) AS INTEGER) * 372 + CAST(SUBSTR(l.last_date, 6, 2) AS INTEGER) * 31 + CAST(SUBSTR(l.last_date, 9, 2) AS INTEGER))
                > a.avg_gap * 2 THEN '이탈 위험'
           ELSE '정상'
       END AS status
FROM last_order l
LEFT JOIN avg_gap a ON a.customer_id = l.customer_id
ORDER BY l.customer_id;

-- 연습 문제
-- 1) 전체 고객을 통틀어 가장 긴 주문 간격(일)과 그 고객 번호를 구하세요.
-- 2) 이탈 위험 기준을 평균 주기의 2배에서 1.5배로 바꾸면 결과가 어떻게 달라지는지 확인하세요.
