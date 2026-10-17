-- Day 5: GROUP BY, HAVING
-- 목표: 데이터를 그룹으로 나누어 집계하고, HAVING으로 그룹에 조건을 거는 방법을 익힌다.

-- 개념 설명
-- GROUP BY 컬럼 : 같은 값을 가진 행끼리 묶어서 그룹마다 집계 함수를 적용한다.
--   예) 고객별 주문 건수, 상품별 매출 합계
-- SELECT에는 GROUP BY에 쓴 컬럼과 집계 함수만 쓰는 것이 안전하다. (MySQL/SQLite 공통)
-- WHERE  : 그룹으로 묶기 "전에" 개별 행을 걸러낸다. (집계 함수 사용 불가)
-- HAVING : 그룹으로 묶고 집계한 "후에" 그룹을 걸러낸다. (집계 함수 사용 가능)
-- 실행 순서: FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY -> LIMIT
-- 두 개 이상의 컬럼으로도 그룹을 만들 수 있다. (GROUP BY customer, product)

-- 준비: 테이블 생성 및 데이터 삽입
CREATE TABLE orders (
    id       INTEGER PRIMARY KEY,
    customer TEXT NOT NULL,
    product  TEXT NOT NULL,
    quantity INTEGER,
    price    INTEGER
);

INSERT INTO orders (id, customer, product, quantity, price) VALUES
    (1, '김민수', '노트북', 1, 1200000),
    (2, '이서연', '마우스', 2,   25000),
    (3, '김민수', '키보드', 1,   70000),
    (4, '박지훈', '마우스', 3,   25000),
    (5, '최유나', '모니터', 2,  300000),
    (6, '이서연', '키보드', 1,   70000),
    (7, '김민수', '마우스', 1,   25000),
    (8, '박지훈', '키보드', 2,   70000);

-- 1) 고객별 주문 건수
SELECT customer, COUNT(*) AS order_count
FROM orders
GROUP BY customer;

-- 2) 상품별 총 판매 수량
SELECT product, SUM(quantity) AS total_quantity
FROM orders
GROUP BY product;

-- 3) 고객별 총 구매 금액 (수량 x 단가), 금액 큰 순서로 정렬
SELECT customer, SUM(quantity * price) AS total_spent
FROM orders
GROUP BY customer
ORDER BY total_spent DESC;

-- 4) 여러 컬럼으로 그룹화: 고객 + 상품별 주문 건수
SELECT customer, product, COUNT(*) AS cnt
FROM orders
GROUP BY customer, product;

-- 5) HAVING: 주문이 2건 이상인 고객만
SELECT customer, COUNT(*) AS order_count
FROM orders
GROUP BY customer
HAVING COUNT(*) >= 2;

-- 6) HAVING: 총 구매 금액이 100,000원을 넘는 고객
SELECT customer, SUM(quantity * price) AS total_spent
FROM orders
GROUP BY customer
HAVING SUM(quantity * price) > 100000;

-- 7) WHERE + GROUP BY + HAVING 함께 사용
--    키보드를 제외한 주문 중, 상품별 판매 수량 합계가 3 이상인 상품
SELECT product, SUM(quantity) AS total_quantity
FROM orders
WHERE product <> '키보드'
GROUP BY product
HAVING SUM(quantity) >= 3
ORDER BY total_quantity DESC;

-- 연습 문제
-- 1) 상품별 주문 건수와 평균 단가를 구하세요.
-- 2) 총 주문 수량이 3 이상인 고객의 이름과 총 주문 수량을 구하세요.
