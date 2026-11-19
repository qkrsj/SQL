-- Day 37: INSERT ... SELECT 와 서브쿼리를 이용한 UPDATE/DELETE
-- 목표: 다른 테이블의 조회 결과로 데이터를 복사·갱신·삭제하는 방법을 익힌다.

-- 개념 설명
--   INSERT ... SELECT : VALUES 대신 SELECT 결과를 그대로 다른 테이블에 넣는다. (백업, 집계 테이블 생성에 유용)
--   UPDATE + 서브쿼리 : SET 컬럼 = (SELECT ...) 로 다른 테이블의 값을 가져와 갱신한다.
--   조건부 UPDATE     : WHERE 절에 IN / EXISTS 서브쿼리를 써서 갱신 대상을 고른다.
--   DELETE + 서브쿼리 : WHERE id IN (SELECT ...) 또는 NOT EXISTS 로 조건에 맞는 행만 삭제한다.
-- 주의: SET 의 서브쿼리는 반드시 값 1개(스칼라)만 반환해야 한다.
--       WHERE 없이 UPDATE/DELETE 를 실행하면 모든 행이 바뀌므로, 먼저 같은 조건으로 SELECT 해서 확인하는 습관을 들인다.
--       UPDATE ... JOIN(MySQL)·UPDATE ... FROM(SQLite) 문법은 DB마다 달라서, 공통으로 쓰이는 서브쿼리 방식을 사용한다.

DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS price_updates;
DROP TABLE IF EXISTS products_backup;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS orders;

CREATE TABLE products (
    id    INTEGER PRIMARY KEY,
    name  VARCHAR(30) NOT NULL,
    price INTEGER NOT NULL
);

CREATE TABLE price_updates (
    product_id INTEGER NOT NULL,
    new_price  INTEGER NOT NULL
);

CREATE TABLE customers (
    id   INTEGER PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    total_spent INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE orders (
    id          INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    amount      INTEGER NOT NULL
);

INSERT INTO products (id, name, price) VALUES
    (1, '노트', 2000), (2, '볼펜', 1000), (3, '가방', 30000), (4, '필통', 5000);

INSERT INTO price_updates (product_id, new_price) VALUES
    (1, 2500), (3, 28000);

INSERT INTO customers (id, name) VALUES
    (1, '민수'), (2, '지영'), (3, '철수'), (4, '영희');

INSERT INTO orders (id, customer_id, amount) VALUES
    (1, 1, 10000), (2, 1, 5000), (3, 2, 20000), (4, 3, 3000);

-- 1) INSERT ... SELECT : 조건에 맞는 행을 백업 테이블로 복사 (구조는 CREATE 후 채운다)
CREATE TABLE products_backup (
    id    INTEGER PRIMARY KEY,
    name  VARCHAR(30) NOT NULL,
    price INTEGER NOT NULL
);

INSERT INTO products_backup (id, name, price)
SELECT id, name, price
FROM products
WHERE price >= 5000;

SELECT * FROM products_backup ORDER BY id;

-- 2) UPDATE + 스칼라 서브쿼리 : 가격 변경표(price_updates)에 있는 상품만 새 가격으로 갱신
--    변경표에 없는 상품은 WHERE EXISTS 로 걸러내지 않으면 NULL 이 들어가 오류가 난다.
UPDATE products
SET price = (SELECT u.new_price FROM price_updates u WHERE u.product_id = products.id)
WHERE EXISTS (SELECT 1 FROM price_updates u WHERE u.product_id = products.id);

SELECT * FROM products ORDER BY id;

-- 3) UPDATE + 집계 서브쿼리 : 고객별 주문 합계를 customers.total_spent 에 반영
--    주문이 없는 고객은 SUM 이 NULL 이므로 COALESCE 로 0 처리한다.
UPDATE customers
SET total_spent = COALESCE(
        (SELECT SUM(o.amount) FROM orders o WHERE o.customer_id = customers.id), 0);

SELECT * FROM customers ORDER BY id;

-- 4) 조건부 UPDATE : 주문 합계가 15000 이상인 고객 이름 뒤에 '(VIP)' 붙이기
UPDATE customers
SET name = name || '(VIP)'
WHERE id IN (SELECT customer_id FROM orders GROUP BY customer_id HAVING SUM(amount) >= 15000);

SELECT * FROM customers ORDER BY id;

-- 5) DELETE + NOT EXISTS : 주문이 한 번도 없는 고객 삭제
DELETE FROM customers
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = customers.id);

SELECT * FROM customers ORDER BY id;

-- 연습 문제
-- 1) products 에서 가격이 1000 이하인 상품만 products_backup 에 추가로 복사해 보세요. (INSERT ... SELECT)
-- 2) orders 를 기준으로 고객별 주문 횟수를 저장할 order_count 컬럼을 customers 에 추가(ALTER TABLE)하고,
--    UPDATE + 서브쿼리로 값을 채워 보세요.
