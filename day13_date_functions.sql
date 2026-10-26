-- Day 13: 날짜 함수
-- 목표: 날짜를 다루는 기본 방법(날짜 비교, 연/월/일 추출, 날짜 더하기, 기간 계산)을 익힌다.

-- 개념 설명
-- 날짜는 'YYYY-MM-DD' 형식 문자열로 저장하면 SQLite·MySQL 모두에서 문자열 비교만으로 날짜 순서 비교가 된다.
-- 날짜 비교         : WHERE order_date >= '2026-02-01' AND order_date < '2026-03-01' (BETWEEN도 가능)
-- 연/월/일 추출     : SUBSTR(order_date, 1, 4) 처럼 문자열로 잘라도 공통으로 쓸 수 있다.
--                     SQLite는 STRFTIME('%Y', d), MySQL은 YEAR(d), MONTH(d), DATE_FORMAT(d, '%Y-%m')을 쓴다.
-- 오늘 날짜         : SQLite는 DATE('now'), MySQL은 CURDATE() (DB마다 다름)
-- 날짜 더하기/빼기  : SQLite는 DATE(d, '+7 days'), MySQL은 DATE_ADD(d, INTERVAL 7 DAY)
-- 날짜 차이(일수)   : SQLite는 JULIANDAY(d2) - JULIANDAY(d1), MySQL은 DATEDIFF(d2, d1)
-- 아래 예제는 SQLite 기준으로 실행되며, MySQL 방식은 주석으로 함께 적어 둔다.

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    id         INTEGER PRIMARY KEY,
    customer   VARCHAR(30) NOT NULL,
    amount     INTEGER NOT NULL,
    order_date DATE NOT NULL,
    ship_date  DATE
);

INSERT INTO orders (id, customer, amount, order_date, ship_date) VALUES
    (1, '김하늘', 15000, '2026-01-15', '2026-01-17'),
    (2, '이바다', 32000, '2026-01-28', '2026-02-01'),
    (3, '박나무', 8000,  '2026-02-03', '2026-02-04'),
    (4, '김하늘', 21000, '2026-02-20', '2026-02-25'),
    (5, '최구름', 45000, '2026-03-05', NULL),
    (6, '이바다', 12000, '2026-03-18', NULL);

-- 1) 날짜 범위 조회: 2026년 2월 주문 (끝 날짜는 "다음 달 1일 미만"으로 쓰면 안전하다)
SELECT id, customer, order_date
FROM orders
WHERE order_date >= '2026-02-01' AND order_date < '2026-03-01';

-- 2) 연/월/일 추출: SUBSTR 방식 (SQLite·MySQL 공통)
SELECT id,
       SUBSTR(order_date, 1, 4) AS yy,
       SUBSTR(order_date, 6, 2) AS mm,
       SUBSTR(order_date, 9, 2) AS dd
FROM orders;

-- 3) STRFTIME: SQLite의 날짜 포맷 함수 (MySQL: DATE_FORMAT(order_date, '%Y-%m'))
SELECT id, STRFTIME('%Y-%m', order_date) AS ym
FROM orders;

-- 4) 월별 주문 건수와 매출 (날짜 추출 + GROUP BY)
SELECT SUBSTR(order_date, 1, 7) AS ym,
       COUNT(*)    AS order_cnt,
       SUM(amount) AS total_amount
FROM orders
GROUP BY SUBSTR(order_date, 1, 7)
ORDER BY ym;

-- 5) 날짜 더하기: 주문일 + 7일 (MySQL: DATE_ADD(order_date, INTERVAL 7 DAY))
SELECT id, order_date, DATE(order_date, '+7 days') AS due_date
FROM orders;

-- 6) 날짜 차이: 주문부터 발송까지 걸린 일수 (MySQL: DATEDIFF(ship_date, order_date))
--    ship_date가 NULL이면 결과도 NULL이다.
SELECT id, order_date, ship_date,
       CAST(JULIANDAY(ship_date) - JULIANDAY(order_date) AS INTEGER) AS days_to_ship
FROM orders;

-- 7) 아직 발송되지 않은 주문 찾기 (NULL은 = 가 아니라 IS NULL)
SELECT id, customer, order_date
FROM orders
WHERE ship_date IS NULL;

-- 8) 요일: STRFTIME('%w')는 0(일요일)~6(토요일). MySQL은 DAYOFWEEK(d)가 1(일요일)~7(토요일)
SELECT id, order_date, STRFTIME('%w', order_date) AS weekday_no
FROM orders;

-- 연습 문제
-- 문제 1) 발송까지 3일 이상 걸린 주문의 id, 고객명, 걸린 일수를 일수가 많은 순으로 출력해 보세요.
--        (힌트: 6번 쿼리의 계산식을 WHERE에 쓰고, ship_date가 NULL인 행은 자동으로 제외된다)
-- 문제 2) 고객별로 가장 최근 주문일(MAX)과 총 주문 금액을 구하고, 2026-02-01 이후에 주문한 고객만 보여 주세요.
--        (힌트: GROUP BY customer 와 HAVING MAX(order_date) >= '2026-02-01')
