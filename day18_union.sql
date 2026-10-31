-- Day 18: 집합 연산 (UNION, UNION ALL)
-- 목표: 여러 SELECT 결과를 위아래로 합치는 UNION / UNION ALL 의 차이와 사용법을 익힌다.

-- 개념 설명
-- JOIN 이 테이블을 "옆으로" 붙이는 것이라면, UNION 은 SELECT 결과를 "아래로" 이어 붙인다.
-- UNION     : 두 결과를 합치고 중복된 행을 제거한다.
-- UNION ALL : 두 결과를 그대로 합친다 (중복 유지, 더 빠르다).
-- 규칙: 합치는 SELECT 들은 컬럼 개수가 같고, 각 위치의 데이터 타입이 서로 호환되어야 한다.
--       결과의 컬럼 이름은 첫 번째 SELECT 의 이름을 따른다.
--       ORDER BY 는 맨 마지막에 한 번만 쓸 수 있다.
-- 이 파일은 SQLite·MySQL 공통 문법만 사용한다.

DROP TABLE IF EXISTS online_orders;
DROP TABLE IF EXISTS store_orders;

CREATE TABLE online_orders (
    id       INTEGER PRIMARY KEY,
    customer VARCHAR(30) NOT NULL,
    amount   INTEGER NOT NULL
);

CREATE TABLE store_orders (
    id       INTEGER PRIMARY KEY,
    customer VARCHAR(30) NOT NULL,
    amount   INTEGER NOT NULL
);

INSERT INTO online_orders (id, customer, amount) VALUES
    (1, '김하늘', 12000),
    (2, '이바다',  8000),
    (3, '김하늘',  5000);

INSERT INTO store_orders (id, customer, amount) VALUES
    (1, '이바다',  8000),
    (2, '박나무', 20000),
    (3, '김하늘',  5000);

-- 1) UNION: 두 채널에 주문한 적 있는 고객 목록 (중복 제거)
SELECT customer FROM online_orders
UNION
SELECT customer FROM store_orders
ORDER BY customer;                     -- 김하늘, 박나무, 이바다 (3행)

-- 2) UNION ALL: 중복을 그대로 둔다 (6행)
SELECT customer FROM online_orders
UNION ALL
SELECT customer FROM store_orders
ORDER BY customer;

-- 3) 채널 구분 컬럼을 붙여서 합치기 (상수 컬럼 활용)
SELECT '온라인' AS channel, customer, amount FROM online_orders
UNION ALL
SELECT '매장'   AS channel, customer, amount FROM store_orders
ORDER BY amount DESC;

-- 4) 합친 결과를 집계하기: 서브쿼리(FROM 절)로 감싸서 고객별 총 구매액을 구한다
SELECT customer, SUM(amount) AS total_amount
FROM (
    SELECT customer, amount FROM online_orders
    UNION ALL
    SELECT customer, amount FROM store_orders
) AS all_orders
GROUP BY customer
ORDER BY total_amount DESC;            -- 김하늘 22000, 박나무 20000, 이바다 16000

-- 연습 문제
-- 1) 두 테이블에서 amount 가 10000 이상인 주문의 고객 이름을 UNION 으로 중복 없이 조회해 보자.
-- 2) UNION 과 UNION ALL 의 결과 행 수가 다른 이유를 직접 두 쿼리를 실행해 비교하고 설명해 보자.
