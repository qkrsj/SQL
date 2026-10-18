-- Day 6: INNER JOIN
-- 목표: 두 테이블을 공통 컬럼으로 연결해 하나의 결과로 조회하는 INNER JOIN을 익힌다.

-- 개념 설명
-- JOIN : 여러 테이블에 나뉘어 저장된 데이터를 키(key) 컬럼으로 연결해서 함께 조회한다.
--   예) customers(고객 정보) + orders(주문 정보) -> 고객 이름과 주문 상품을 한 번에 보기
-- INNER JOIN : 양쪽 테이블에서 ON 조건이 일치하는 행만 결과에 포함한다.
--   (한쪽에만 있는 행은 결과에서 빠진다. JOIN만 써도 INNER JOIN이다.)
-- 문법: FROM 테이블A a INNER JOIN 테이블B b ON a.키 = b.키
-- 별칭(alias) : 테이블에 짧은 이름(c, o 등)을 붙여 쓰면 쿼리가 간결해진다.
-- 컬럼 이름이 양쪽에 모두 있으면 c.id 처럼 테이블 별칭을 앞에 붙여 구분한다.
-- JOIN 후에도 WHERE, GROUP BY, HAVING, ORDER BY를 그대로 사용할 수 있다.

-- 준비: 테이블 생성 및 데이터 삽입
CREATE TABLE customers (
    id   INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE orders (
    id          INTEGER PRIMARY KEY,
    customer_id INTEGER,
    product     TEXT NOT NULL,
    quantity    INTEGER,
    price       INTEGER
);

INSERT INTO customers (id, name, city) VALUES
    (1, '김민수', '서울'),
    (2, '이서연', '부산'),
    (3, '박지훈', '서울'),
    (4, '최유나', '대전');   -- 주문이 없는 고객

INSERT INTO orders (id, customer_id, product, quantity, price) VALUES
    (1, 1, '노트북', 1, 1200000),
    (2, 2, '마우스', 2,   25000),
    (3, 1, '키보드', 1,   70000),
    (4, 3, '마우스', 3,   25000),
    (5, 2, '키보드', 1,   70000),
    (6, 9, '모니터', 1,  300000);  -- 존재하지 않는 고객(9)의 주문

-- 1) 기본 INNER JOIN: 주문마다 고객 이름 붙이기
SELECT o.id AS order_id, c.name, o.product
FROM orders o
INNER JOIN customers c ON o.customer_id = c.id;
-- 고객 4번(주문 없음)과 주문 6번(고객 없음)은 결과에 나오지 않는다.

-- 2) 필요한 컬럼만 골라 조회하고 정렬
SELECT c.name, c.city, o.product, o.quantity * o.price AS amount
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
ORDER BY amount DESC;

-- 3) JOIN + WHERE: 서울에 사는 고객의 주문만
SELECT c.name, o.product
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
WHERE c.city = '서울';

-- 4) JOIN + GROUP BY: 고객별 주문 건수와 총 구매 금액
SELECT c.name,
       COUNT(*) AS order_count,
       SUM(o.quantity * o.price) AS total_spent
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY total_spent DESC;

-- 5) JOIN + GROUP BY + HAVING: 총 구매 금액이 100,000원 이상인 고객
SELECT c.name, SUM(o.quantity * o.price) AS total_spent
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
HAVING SUM(o.quantity * o.price) >= 100000;

-- 연습 문제
-- 1) 도시별 총 주문 수량을 구하세요. (customers와 orders를 JOIN)
-- 2) '마우스'를 주문한 고객의 이름과 도시를 중복 없이 조회하세요.
