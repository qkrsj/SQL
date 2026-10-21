-- Day 8: 서브쿼리 (Subquery)
-- 목표: 쿼리 안에 쿼리를 넣어 단계적으로 조건을 계산하는 방법을 익힌다.

-- 개념 설명
-- 서브쿼리 : 괄호 ( ) 로 감싼 SELECT 문. 다른 쿼리의 일부로 사용된다.
-- 1) 스칼라 서브쿼리 : 값 하나(1행 1열)를 반환 -> 비교 연산자(=, >, <)와 함께 사용
-- 2) 다중 행 서브쿼리 : 여러 행을 반환 -> IN, NOT IN, EXISTS와 함께 사용
-- 3) FROM 절 서브쿼리(인라인 뷰) : 결과를 임시 테이블처럼 사용 (반드시 별칭 필요)
-- 4) 상관 서브쿼리 : 바깥 쿼리의 컬럼을 참조하므로 바깥 행마다 다시 실행된다.
-- 주의: NOT IN 서브쿼리 결과에 NULL이 하나라도 있으면 결과가 비어 버린다.
--   NULL 가능성이 있다면 NOT EXISTS를 사용하는 편이 안전하다.

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
    (6, 3, '모니터', 1,  300000);

-- 1) 스칼라 서브쿼리: 평균 가격보다 비싼 주문
SELECT id, product, price
FROM orders
WHERE price > (SELECT AVG(price) FROM orders);

-- 2) IN 서브쿼리: 서울에 사는 고객의 주문
SELECT id, product, customer_id
FROM orders
WHERE customer_id IN (SELECT id FROM customers WHERE city = '서울');

-- 3) NOT IN 서브쿼리: 주문한 적 없는 고객
-- (orders.customer_id에 NULL이 없을 때만 안전하다.)
SELECT name
FROM customers
WHERE id NOT IN (SELECT customer_id FROM orders);

-- 4) SELECT 절 서브쿼리: 고객별 주문 건수
SELECT c.name,
       (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.id) AS order_count
FROM customers c;

-- 5) FROM 절 서브쿼리(인라인 뷰): 고객별 총 주문 금액 중 100만 원 이상만 조회
SELECT t.customer_id, t.total
FROM (
    SELECT customer_id, SUM(quantity * price) AS total
    FROM orders
    GROUP BY customer_id
) AS t
WHERE t.total >= 1000000;

-- 6) 상관 서브쿼리 + EXISTS: 주문이 한 건이라도 있는 고객
SELECT c.name
FROM customers c
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.id);

-- 연습 문제
-- 문제 1) 가장 비싼 단가(price)의 주문 정보를 서브쿼리로 조회해 보세요.
-- 문제 2) 주문 건수가 2건 이상인 고객의 이름을 IN 서브쿼리로 조회해 보세요.
