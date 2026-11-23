-- Day 41: RFM 고객 분석
-- 목표: 최근성(Recency), 빈도(Frequency), 금액(Monetary)으로 고객을 점수화하고 등급을 나눈다.

-- 개념 설명
--   R (Recency)   : 마지막 주문이 기준일로부터 얼마나 최근인가 (작을수록 좋음)
--   F (Frequency) : 주문 횟수 (클수록 좋음)
--   M (Monetary)  : 총 구매 금액 (클수록 좋음)
--   NTILE(n)      : 정렬된 행을 n개 구간으로 균등 분할해 1..n 번호를 매기는 윈도우 함수
--   기준일은 고정값('2026-04-30')으로 두고, 날짜 차이는 YYYY-MM-DD 문자열을
--   연*372 + 월*31 + 일 로 환산한 근사 일수로 계산해 SQLite, MySQL 모두에서 동작하게 한다.
--   (윈도우 함수와 CTE 는 MySQL 8.0 / SQLite 3.25 이상)

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    id          INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date  VARCHAR(10) NOT NULL,
    amount      INTEGER NOT NULL
);

INSERT INTO orders (id, customer_id, order_date, amount) VALUES
    (1, 101, '2026-01-05', 30000), (2, 101, '2026-02-03', 45000), (3, 101, '2026-04-25', 60000),
    (4, 102, '2026-01-10', 20000), (5, 102, '2026-03-01', 15000),
    (6, 103, '2026-01-20', 80000),
    (7, 104, '2026-02-14', 25000), (8, 104, '2026-03-20', 35000), (9, 104, '2026-04-20', 40000),
    (10, 105, '2026-02-20', 10000), (11, 105, '2026-04-10', 12000),
    (12, 106, '2026-03-22', 90000), (13, 106, '2026-04-28', 110000);

-- 1) 고객별 R, F, M 원본 값
SELECT customer_id,
       MAX(order_date) AS last_order,
       COUNT(*)        AS frequency,
       SUM(amount)     AS monetary
FROM orders
GROUP BY customer_id
ORDER BY customer_id;

-- 2) 최근성(일수): 기준일 - 마지막 주문일 (근사 일수)
SELECT customer_id,
       MAX(order_date) AS last_order,
       (CAST(SUBSTR('2026-04-30', 1, 4) AS INTEGER) * 372 + CAST(SUBSTR('2026-04-30', 6, 2) AS INTEGER) * 31 + CAST(SUBSTR('2026-04-30', 9, 2) AS INTEGER))
     - (CAST(SUBSTR(MAX(order_date), 1, 4) AS INTEGER) * 372 + CAST(SUBSTR(MAX(order_date), 6, 2) AS INTEGER) * 31 + CAST(SUBSTR(MAX(order_date), 9, 2) AS INTEGER))
       AS recency_days
FROM orders
GROUP BY customer_id
ORDER BY recency_days;

-- 3) NTILE 로 1~3점 부여 (3점이 가장 좋음)
--    R 은 일수가 작을수록 좋으므로 내림차순 정렬로 작은 값이 높은 점수를 받게 한다.
WITH base AS (
    SELECT customer_id,
           (CAST(SUBSTR('2026-04-30', 1, 4) AS INTEGER) * 372 + CAST(SUBSTR('2026-04-30', 6, 2) AS INTEGER) * 31 + CAST(SUBSTR('2026-04-30', 9, 2) AS INTEGER))
         - (CAST(SUBSTR(MAX(order_date), 1, 4) AS INTEGER) * 372 + CAST(SUBSTR(MAX(order_date), 6, 2) AS INTEGER) * 31 + CAST(SUBSTR(MAX(order_date), 9, 2) AS INTEGER))
           AS recency_days,
           COUNT(*)    AS frequency,
           SUM(amount) AS monetary
    FROM orders
    GROUP BY customer_id
)
SELECT customer_id, recency_days, frequency, monetary,
       NTILE(3) OVER (ORDER BY recency_days DESC, customer_id) AS r_score,
       NTILE(3) OVER (ORDER BY frequency, customer_id)         AS f_score,
       NTILE(3) OVER (ORDER BY monetary, customer_id)          AS m_score
FROM base
ORDER BY customer_id;

-- 4) 점수 합계로 등급 나누기 (CASE WHEN)
WITH base AS (
    SELECT customer_id,
           (CAST(SUBSTR('2026-04-30', 1, 4) AS INTEGER) * 372 + CAST(SUBSTR('2026-04-30', 6, 2) AS INTEGER) * 31 + CAST(SUBSTR('2026-04-30', 9, 2) AS INTEGER))
         - (CAST(SUBSTR(MAX(order_date), 1, 4) AS INTEGER) * 372 + CAST(SUBSTR(MAX(order_date), 6, 2) AS INTEGER) * 31 + CAST(SUBSTR(MAX(order_date), 9, 2) AS INTEGER))
           AS recency_days,
           COUNT(*)    AS frequency,
           SUM(amount) AS monetary
    FROM orders
    GROUP BY customer_id
),
scored AS (
    SELECT customer_id, recency_days, frequency, monetary,
           NTILE(3) OVER (ORDER BY recency_days DESC, customer_id) AS r_score,
           NTILE(3) OVER (ORDER BY frequency, customer_id)         AS f_score,
           NTILE(3) OVER (ORDER BY monetary, customer_id)          AS m_score
    FROM base
)
SELECT customer_id, r_score, f_score, m_score,
       r_score + f_score + m_score AS total_score,
       CASE
           WHEN r_score + f_score + m_score >= 8 THEN 'VIP'
           WHEN r_score + f_score + m_score >= 5 THEN '일반'
           ELSE '이탈 위험'
       END AS grade
FROM scored
ORDER BY total_score DESC, customer_id;

-- 연습 문제
-- 1) 4번 쿼리를 이용해 등급별 고객 수와 평균 구매 금액(monetary)을 조회해 보세요.
-- 2) R 점수는 높지만(3점) F 점수가 낮은(1점) '최근 첫 구매 고객'의 customer_id 를 찾아보세요.
