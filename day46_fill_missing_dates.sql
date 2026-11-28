-- Day 46: 빠진 날짜 채우기 (일별 매출 달력 만들기)
-- 목표: 주문이 없는 날도 0원으로 보이도록 날짜 목록(달력)을 만들고 LEFT JOIN 으로 채운다.

-- 개념 설명
--   daily_sales 처럼 "주문이 있는 날"만 행으로 저장된 표를 GROUP BY 하면 주문이 없는 날은 결과에서 사라진다.
--   그러면 그래프에 빈 날이 생기거나 이동 평균·연속 일수 계산이 틀어진다.
--   해결 방법: 1) 재귀 CTE 로 날짜 목록(달력)을 만든다.
--             2) 달력을 기준(왼쪽)으로 LEFT JOIN 한다.
--             3) 매출이 없는 날은 COALESCE(값, 0) 으로 0 처리한다.
--   달력이 왼쪽이어야 한다. 주문 테이블이 왼쪽이면 빠진 날은 여전히 나오지 않는다.
--   DATE(d, '+1 day') 는 SQLite 문법이다. (MySQL 에서는 DATE_ADD(d, INTERVAL 1 DAY) 를 사용한다.)

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id    INTEGER PRIMARY KEY,
    order_date  DATE    NOT NULL,
    amount      INTEGER NOT NULL
);

INSERT INTO orders (order_id, order_date, amount) VALUES
    (1, '2026-11-01', 12000),
    (2, '2026-11-01', 8000),
    (3, '2026-11-02', 15000),
    (4, '2026-11-04', 30000),
    (5, '2026-11-04', 5000),
    (6, '2026-11-07', 22000),
    (7, '2026-11-08', 9000);

-- 1) 단순 집계: 주문이 없는 11-03, 11-05, 11-06 이 결과에서 빠진다
SELECT order_date, SUM(amount) AS total_amount
FROM orders
GROUP BY order_date
ORDER BY order_date;

-- 2) 11-01 ~ 11-08 달력 만들기 (재귀 CTE)
WITH RECURSIVE calendar(d) AS (
    SELECT DATE('2026-11-01')
    UNION ALL
    SELECT DATE(d, '+1 day') FROM calendar
    WHERE d < DATE('2026-11-08')
)
SELECT d FROM calendar;

-- 3) 달력 + LEFT JOIN + COALESCE: 빠진 날도 0원으로 표시
WITH RECURSIVE calendar(d) AS (
    SELECT DATE('2026-11-01')
    UNION ALL
    SELECT DATE(d, '+1 day') FROM calendar
    WHERE d < DATE('2026-11-08')
)
SELECT c.d                              AS sale_date,
       COUNT(o.order_id)                AS order_cnt,
       COALESCE(SUM(o.amount), 0)       AS total_amount
FROM calendar c
LEFT JOIN orders o ON o.order_date = c.d
GROUP BY c.d
ORDER BY c.d;

-- 4) 주문이 하나도 없는 날짜만 찾기
WITH RECURSIVE calendar(d) AS (
    SELECT DATE('2026-11-01')
    UNION ALL
    SELECT DATE(d, '+1 day') FROM calendar
    WHERE d < DATE('2026-11-08')
)
SELECT c.d AS no_order_date
FROM calendar c
LEFT JOIN orders o ON o.order_date = c.d
WHERE o.order_id IS NULL
ORDER BY c.d;

-- 5) 빠진 날을 채운 뒤 3일 이동 평균 (당일 포함 최근 3일)
WITH RECURSIVE calendar(d) AS (
    SELECT DATE('2026-11-01')
    UNION ALL
    SELECT DATE(d, '+1 day') FROM calendar
    WHERE d < DATE('2026-11-08')
),
daily AS (
    SELECT c.d AS sale_date,
           COALESCE(SUM(o.amount), 0) AS total_amount
    FROM calendar c
    LEFT JOIN orders o ON o.order_date = c.d
    GROUP BY c.d
)
SELECT sale_date,
       total_amount,
       ROUND(AVG(total_amount) OVER (
           ORDER BY sale_date
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ), 0) AS moving_avg_3d
FROM daily
ORDER BY sale_date;

-- 연습 문제
-- 1) 11-01 ~ 11-10 달력으로 확장해 11-09, 11-10 도 0원으로 나오는지 확인해 보세요.
-- 2) 주문이 없는 날이 연속으로 가장 길게 이어진 구간(시작일, 일수)을 구해 보세요. (힌트: Day 29)
