-- Day 4: 집계 함수 (COUNT, SUM, AVG)
-- 목표: 여러 행을 하나의 값으로 요약하는 집계 함수(COUNT, SUM, AVG, MIN, MAX)를 익힌다.

-- 개념 설명
-- 집계 함수는 여러 행을 입력받아 하나의 결과 값을 돌려준다.
--   COUNT(*)    : NULL 여부와 상관없이 전체 행 수
--   COUNT(컬럼) : 해당 컬럼이 NULL이 아닌 행 수
--   SUM(컬럼)   : 합계
--   AVG(컬럼)   : 평균 (NULL은 계산에서 제외된다)
--   MIN / MAX   : 최솟값 / 최댓값
-- WHERE로 먼저 행을 걸러낸 뒤 집계가 적용된다.
-- COUNT(DISTINCT 컬럼)은 중복을 제거한 개수를 센다.
-- 주의: 집계 함수는 WHERE 절에서 사용할 수 없다. (조건은 Day 5의 HAVING에서 다룬다)

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
    (6, '이서연', '키보드', NULL, 70000);

-- 1) 전체 행 수
SELECT COUNT(*) AS total_orders FROM orders;

-- 2) NULL 제외 개수: quantity가 NULL인 행은 빠진다 (결과 5)
SELECT COUNT(quantity) AS quantity_count FROM orders;

-- 3) 중복 제거 개수: 주문한 고객 수
SELECT COUNT(DISTINCT customer) AS customer_count FROM orders;

-- 4) 합계: 총 주문 수량
SELECT SUM(quantity) AS total_quantity FROM orders;

-- 5) 평균: 상품 단가 평균
SELECT AVG(price) AS avg_price FROM orders;

-- 6) 최솟값, 최댓값
SELECT MIN(price) AS min_price, MAX(price) AS max_price FROM orders;

-- 7) 계산식과 함께: 전체 매출 (수량 x 단가, NULL 수량은 제외됨)
SELECT SUM(quantity * price) AS total_sales FROM orders;

-- 8) WHERE와 함께: 마우스 주문의 총 수량
SELECT SUM(quantity) AS mouse_quantity FROM orders WHERE product = '마우스';

-- 9) 여러 집계 함수를 한 번에
SELECT COUNT(*) AS cnt, SUM(price) AS sum_price, ROUND(AVG(price), 1) AS avg_price
FROM orders;

-- 연습 문제
-- 1) 김민수가 주문한 건수와 단가(price) 합계를 구하세요.
-- 2) 수량(quantity)이 2 이상인 주문의 평균 단가를 구하세요.
