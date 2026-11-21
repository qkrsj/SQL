-- Day 39: 신규 고객 vs 재구매 고객 구분
-- 목표: 고객의 첫 주문을 기준으로 주문을 '신규'와 '재구매'로 나누고 재구매율을 계산한다.

-- 개념 설명
--   첫 주문일     : MIN(order_date) 를 고객별(GROUP BY 또는 PARTITION BY)로 구한다.
--   신규 주문     : 주문일 = 그 고객의 첫 주문일
--   재구매 주문   : 주문일 > 그 고객의 첫 주문일
--   재구매 고객   : 주문 횟수가 2회 이상인 고객 (HAVING COUNT(*) >= 2)
--   재구매율      : 재구매 고객 수 / 전체 고객 수 * 100
--   주의: 같은 날 여러 번 주문한 경우를 구분하려면 주문일 대신 ROW_NUMBER() 순번(rn = 1)을 쓴다.
--   MIN() OVER 와 ROW_NUMBER() 는 MySQL 8.0 / SQLite 3.25 이상에서 사용할 수 있다.

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    id          INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date  VARCHAR(10) NOT NULL,
    amount      INTEGER NOT NULL
);

INSERT INTO orders (id, customer_id, order_date, amount) VALUES
    (1, 101, '2026-01-05', 30000), (2, 102, '2026-01-10', 15000),
    (3, 101, '2026-02-03', 20000), (4, 103, '2026-02-14', 50000),
    (5, 104, '2026-02-20', 12000), (6, 102, '2026-03-01', 18000),
    (7, 101, '2026-03-15', 25000), (8, 105, '2026-03-20', 40000),
    (9, 103, '2026-03-25', 22000), (10, 106, '2026-03-28', 9000);

-- 1) 고객별 첫 주문일과 주문 횟수
SELECT customer_id,
       MIN(order_date) AS first_order,
       COUNT(*)        AS order_cnt
FROM orders
GROUP BY customer_id
ORDER BY customer_id;

-- 2) 주문마다 신규/재구매 표시 (MIN OVER 로 고객별 첫 주문일을 옆에 붙인다)
SELECT id, customer_id, order_date, amount,
       CASE WHEN order_date = MIN(order_date) OVER (PARTITION BY customer_id)
            THEN '신규' ELSE '재구매' END AS order_type
FROM orders
ORDER BY order_date, id;

-- 3) 월별 신규 주문 vs 재구매 주문 매출 (서브쿼리로 구분 후 SUBSTR 로 월 추출)
SELECT SUBSTR(order_date, 1, 7) AS ym,
       SUM(CASE WHEN order_type = '신규'   THEN amount ELSE 0 END) AS new_sales,
       SUM(CASE WHEN order_type = '재구매' THEN amount ELSE 0 END) AS repeat_sales
FROM (
    SELECT order_date, amount,
           CASE WHEN order_date = MIN(order_date) OVER (PARTITION BY customer_id)
                THEN '신규' ELSE '재구매' END AS order_type
    FROM orders
) t
GROUP BY SUBSTR(order_date, 1, 7)
ORDER BY ym;

-- 4) 재구매율: 2회 이상 주문한 고객 비율 (6명 중 3명 -> 50.0)
SELECT COUNT(*) AS total_customers,
       SUM(CASE WHEN cnt >= 2 THEN 1 ELSE 0 END) AS repeat_customers,
       ROUND(100.0 * SUM(CASE WHEN cnt >= 2 THEN 1 ELSE 0 END) / COUNT(*), 1) AS repeat_rate
FROM (
    SELECT customer_id, COUNT(*) AS cnt
    FROM orders
    GROUP BY customer_id
) t;

-- 5) 고객별 두 번째 주문일 조회 (ROW_NUMBER 순번이 2인 행만 선택)
SELECT customer_id, order_date AS second_order_date
FROM (
    SELECT customer_id, order_date,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date, id) AS rn
    FROM orders
) t
WHERE rn = 2
ORDER BY customer_id;

-- 연습 문제
-- 문제 1) 고객별 첫 주문 금액과 전체 주문 금액 합계를 함께 조회하시오.
-- 문제 2) 3월에 처음 주문한 '신규 고객' 수와 3월 주문 중 '재구매 주문' 건수를 각각 구하시오.
