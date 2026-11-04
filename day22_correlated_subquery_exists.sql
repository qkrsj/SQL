-- Day 22: 상관 서브쿼리와 EXISTS / NOT EXISTS
-- 목표: 바깥 쿼리의 값을 참조하는 상관 서브쿼리를 이해하고, EXISTS·NOT EXISTS 와 NOT IN 의 NULL 함정을 구분한다.

-- 개념 설명
-- 상관 서브쿼리: 서브쿼리 안에서 바깥 쿼리의 컬럼을 참조하는 서브쿼리. 바깥 행마다 한 번씩 평가된다.
-- EXISTS (서브쿼리): 서브쿼리 결과가 한 행이라도 있으면 TRUE. 안의 SELECT 목록은 무엇이든 상관없어 보통 SELECT 1 을 쓴다.
-- NOT EXISTS: 서브쿼리 결과가 한 행도 없을 때 TRUE. "~가 없는 것" 을 찾을 때 쓴다.
-- NOT IN 함정: 서브쿼리 결과에 NULL 이 하나라도 있으면 NOT IN 은 결과가 비어 버린다.
--   (x NOT IN (1, NULL) 은 UNKNOWN 이 되기 때문) -> NULL 가능성이 있으면 NOT EXISTS 를 사용한다.
-- 스칼라 상관 서브쿼리: SELECT 목록에 넣어 행마다 계산값(예: 주문 수)을 붙일 수도 있다.
-- 이 파일은 SQLite·MySQL 공통 문법만 사용한다.

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    id   INTEGER PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    city VARCHAR(20) NOT NULL
);

CREATE TABLE orders (
    id          INTEGER PRIMARY KEY,
    customer_id INTEGER,            -- 비회원 주문이면 NULL
    amount      INTEGER NOT NULL
);

INSERT INTO customers (id, name, city) VALUES
    (1, '김민수', '서울'),
    (2, '이영희', '부산'),
    (3, '박철수', '서울'),
    (4, '최지우', '대구'),
    (5, '정하나', '부산');

INSERT INTO orders (id, customer_id, amount) VALUES
    (1, 1, 30000),
    (2, 1, 15000),
    (3, 2, 50000),
    (4, 3, 8000),
    (5, NULL, 12000);               -- 비회원 주문

-- 1) EXISTS: 주문이 한 건이라도 있는 고객
SELECT c.name
FROM customers c
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.id);
-- 결과: 김민수, 이영희, 박철수

-- 2) NOT EXISTS: 주문이 한 건도 없는 고객
SELECT c.name
FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.id);
-- 결과: 최지우, 정하나

-- 3) NOT IN 의 함정: orders.customer_id 에 NULL 이 있어서 결과가 0행이 된다
SELECT c.name
FROM customers c
WHERE c.id NOT IN (SELECT customer_id FROM orders);
-- 결과: (없음) -> 2번과 결과가 다르다!

-- 4) NOT IN 을 쓰려면 서브쿼리에서 NULL 을 걸러낸다
SELECT c.name
FROM customers c
WHERE c.id NOT IN (SELECT customer_id FROM orders WHERE customer_id IS NOT NULL);
-- 결과: 최지우, 정하나

-- 5) 스칼라 상관 서브쿼리: 고객별 주문 건수와 총액 붙이기
SELECT c.name,
       (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.id) AS 주문수,
       (SELECT COALESCE(SUM(o.amount), 0) FROM orders o WHERE o.customer_id = c.id) AS 총액
FROM customers c;
-- 김민수 2/45000, 이영희 1/50000, 박철수 1/8000, 최지우 0/0, 정하나 0/0

-- 6) 상관 서브쿼리 + 비교: 자기 도시 고객 평균 주문액보다 큰 주문을 한 적 있는 고객
--    (각 고객의 도시 안에서 주문을 비교)
SELECT DISTINCT c.name
FROM customers c
JOIN orders o ON o.customer_id = c.id
WHERE o.amount > (
    SELECT AVG(o2.amount)
    FROM orders o2
    JOIN customers c2 ON c2.id = o2.customer_id
    WHERE c2.city = c.city
);
-- 서울 평균 (30000+15000+8000)/3 ≈ 17667 -> 김민수(30000) / 부산 평균 50000 -> 해당 없음
-- 결과: 김민수

-- 연습 문제
-- 문제 1) 서울에 사는 고객 중 주문 금액이 20000 이상인 주문을 한 번이라도 한 고객의 이름을 EXISTS 로 조회하세요.
-- 문제 2) 부산에 사는 고객 중 주문이 없는 고객의 이름을 NOT EXISTS 로 조회하고, 같은 결과가 NOT IN 으로도 나오는지 비교해 보세요.
