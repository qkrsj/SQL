-- Day 7: LEFT / RIGHT JOIN
-- 목표: 한쪽 테이블의 행을 모두 보존하는 외부 조인(OUTER JOIN)을 익힌다.

-- 개념 설명
-- INNER JOIN : 양쪽에 모두 일치하는 행만 남긴다.
-- LEFT JOIN  : 왼쪽(FROM) 테이블의 모든 행을 남기고, 오른쪽에 일치하는 행이 없으면 오른쪽 컬럼을 NULL로 채운다.
-- RIGHT JOIN : LEFT JOIN의 반대. 오른쪽(JOIN) 테이블의 모든 행을 남긴다.
--   (테이블 순서만 바꾸면 LEFT JOIN으로 똑같이 쓸 수 있어서 실무에서는 LEFT JOIN을 더 많이 쓴다.)
--   참고: SQLite는 3.39.0 버전부터 RIGHT JOIN을 지원한다.
-- "없는 것 찾기" 패턴 : LEFT JOIN 후 WHERE 오른쪽.키 IS NULL -> 짝이 없는 행만 조회
-- 주의: 오른쪽 테이블 조건을 WHERE에 쓰면 NULL 행이 걸러져 INNER JOIN처럼 동작한다.
--   조건을 유지하면서 왼쪽 행을 보존하려면 ON 절에 조건을 넣는다.

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

-- 1) LEFT JOIN: 모든 고객을 보여주고 주문이 없으면 NULL
SELECT c.name, o.product
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id;
-- 최유나는 주문이 없지만 product가 NULL인 채로 결과에 포함된다.

-- 2) 주문하지 않은 고객 찾기 (LEFT JOIN + IS NULL)
SELECT c.name
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.id IS NULL;

-- 3) 고객별 주문 건수 (주문 0건인 고객도 포함)
-- COUNT(o.id)는 NULL을 세지 않으므로 주문이 없으면 0이 된다. (COUNT(*)를 쓰면 1로 잘못 나온다.)
SELECT c.name, COUNT(o.id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY order_count DESC;

-- 4) ON 절에 조건 넣기: 모든 고객을 보여주되 '마우스' 주문만 붙이기
SELECT c.name, o.product
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id AND o.product = '마우스';

-- 5) RIGHT JOIN: 모든 주문을 보여주고 고객이 없으면 NULL (SQLite 3.39+, MySQL)
SELECT o.id AS order_id, o.product, c.name
FROM customers c
RIGHT JOIN orders o ON c.id = o.customer_id;
-- 6번 주문(고객 9번)은 name이 NULL로 나온다.

-- 6) 고객 정보가 없는 주문 찾기 (RIGHT JOIN과 같은 결과를 LEFT JOIN으로)
SELECT o.id AS order_id, o.product
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.id
WHERE c.id IS NULL;

-- 연습 문제
-- 1) 모든 고객의 이름과 총 구매금액(quantity * price 합계)을 조회하세요. 주문이 없는 고객은 0으로 표시하세요. (힌트: COALESCE)
-- 2) 서울에 사는 고객 중 주문 내역이 없는 고객의 이름을 조회하세요.
