-- Day 9: INSERT / UPDATE / DELETE
-- 목표: 테이블의 데이터를 추가(INSERT), 수정(UPDATE), 삭제(DELETE)하는 방법을 익힌다.

-- 개념 설명
-- INSERT INTO 테이블 (컬럼들) VALUES (값들) : 새 행을 추가한다.
--   - 여러 행을 한 번에 넣으려면 VALUES (...), (...) 처럼 쉼표로 이어 쓴다.
--   - INSERT INTO ... SELECT ... 로 다른 테이블의 조회 결과를 복사해 넣을 수도 있다.
-- UPDATE 테이블 SET 컬럼 = 값 [WHERE 조건] : 기존 행의 값을 바꾼다.
-- DELETE FROM 테이블 [WHERE 조건] : 행을 삭제한다.
-- 주의: UPDATE와 DELETE에 WHERE를 빼먹으면 "모든 행"이 바뀌거나 지워진다!
--   실행 전에 같은 WHERE 조건으로 SELECT를 먼저 해 보는 습관을 들이자.

-- 준비: 테이블 생성
CREATE TABLE products (
    id    INTEGER PRIMARY KEY,
    name  TEXT NOT NULL,
    price INTEGER,
    stock INTEGER
);

-- 1) INSERT: 한 행 추가
INSERT INTO products (id, name, price, stock) VALUES (1, '노트북', 1200000, 5);

-- 2) INSERT: 여러 행을 한 번에 추가
INSERT INTO products (id, name, price, stock) VALUES
    (2, '마우스',   25000, 50),
    (3, '키보드',   70000, 30),
    (4, '모니터',  300000, 10),
    (5, '웹캠',     45000,  0);

SELECT * FROM products;

-- 3) INSERT ... SELECT: 조회 결과를 다른 테이블에 복사
CREATE TABLE sold_out_products (
    id   INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);

INSERT INTO sold_out_products (id, name)
SELECT id, name FROM products WHERE stock = 0;

SELECT * FROM sold_out_products;

-- 4) UPDATE: 특정 행의 값 수정 (먼저 SELECT로 대상 확인)
SELECT * FROM products WHERE name = '마우스';
UPDATE products SET price = 27000 WHERE name = '마우스';

-- 5) UPDATE: 여러 컬럼 동시에 수정 + 계산식 사용
UPDATE products
SET price = price * 9 / 10,   -- 10% 할인 (정수 계산)
    stock = stock + 5
WHERE price >= 100000;

SELECT * FROM products;

-- 6) DELETE: 조건에 맞는 행 삭제
SELECT * FROM products WHERE stock = 0;
DELETE FROM products WHERE stock = 0;

SELECT * FROM products;

-- 7) DELETE: WHERE 없이 실행하면 모든 행이 삭제된다 (테이블 구조는 남는다)
DELETE FROM sold_out_products;
SELECT COUNT(*) AS remaining FROM sold_out_products;

-- 연습 문제
-- 문제 1) products에 (6, '헤드셋', 80000, 20) 행을 추가하고,
--        가격이 50000 이하인 상품의 재고(stock)를 모두 10씩 늘려 보세요.
-- 문제 2) 재고가 10 미만인 상품을 삭제하기 전에 SELECT로 먼저 확인한 뒤,
--        DELETE로 삭제해 보세요.
