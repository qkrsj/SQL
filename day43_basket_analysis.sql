-- Day 43: 장바구니 분석 (함께 구매한 상품)
-- 목표: 셀프 조인으로 같은 주문에 함께 담긴 상품 쌍을 세고, 지지도(support)와 신뢰도(confidence)를 계산한다.

-- 개념 설명
--   order_items 는 주문 1건에 상품 여러 개가 담긴 구조(주문번호 + 상품명)이다.
--   같은 주문번호끼리 셀프 조인하고 a.product < b.product 조건을 주면
--   (A,B) 와 (B,A) 중복 없이 상품 쌍을 한 번씩만 얻는다.
--   지지도(support)   = 두 상품이 함께 담긴 주문 수 / 전체 주문 수
--   신뢰도(confidence) = A 와 B 가 함께 담긴 주문 수 / A 가 담긴 주문 수
--   SQLite, MySQL 공통 문법만 사용한다. (CTE 는 MySQL 8.0 / SQLite 3.8.3 이상)

DROP TABLE IF EXISTS order_items;

CREATE TABLE order_items (
    order_id INTEGER NOT NULL,
    product  VARCHAR(20) NOT NULL,
    PRIMARY KEY (order_id, product)
);

INSERT INTO order_items (order_id, product) VALUES
    (1, '라면'), (1, '계란'), (1, '김치'),
    (2, '라면'), (2, '계란'),
    (3, '우유'), (3, '빵'),
    (4, '라면'), (4, '김치'),
    (5, '우유'), (5, '빵'), (5, '계란'),
    (6, '라면'), (6, '계란'), (6, '김치'), (6, '우유');

-- 1) 같은 주문에 함께 담긴 상품 쌍과 횟수
SELECT a.product AS product_a,
       b.product AS product_b,
       COUNT(*)  AS pair_cnt
FROM order_items a
JOIN order_items b
  ON a.order_id = b.order_id
 AND a.product < b.product
GROUP BY a.product, b.product
ORDER BY pair_cnt DESC, product_a, product_b;

-- 2) 상품별 주문 수 (신뢰도 계산의 분모)
SELECT product, COUNT(*) AS order_cnt
FROM order_items
GROUP BY product
ORDER BY order_cnt DESC, product;

-- 3) 지지도와 신뢰도 계산 (2회 이상 함께 구매된 쌍만)
WITH pairs AS (
    SELECT a.product AS product_a, b.product AS product_b, COUNT(*) AS pair_cnt
    FROM order_items a
    JOIN order_items b
      ON a.order_id = b.order_id AND a.product < b.product
    GROUP BY a.product, b.product
    HAVING COUNT(*) >= 2
),
prod_cnt AS (
    SELECT product, COUNT(*) AS cnt FROM order_items GROUP BY product
),
total AS (
    SELECT COUNT(DISTINCT order_id) AS total_orders FROM order_items
)
SELECT p.product_a, p.product_b, p.pair_cnt,
       ROUND(p.pair_cnt * 1.0 / t.total_orders, 2) AS support,
       ROUND(p.pair_cnt * 1.0 / pa.cnt, 2)         AS confidence_a_to_b,
       ROUND(p.pair_cnt * 1.0 / pb.cnt, 2)         AS confidence_b_to_a
FROM pairs p
JOIN prod_cnt pa ON pa.product = p.product_a
JOIN prod_cnt pb ON pb.product = p.product_b
CROSS JOIN total t
ORDER BY p.pair_cnt DESC, p.product_a, p.product_b;

-- 4) '라면'을 산 주문에 같이 담긴 다른 상품 추천 순위
SELECT o2.product AS recommended, COUNT(*) AS together_cnt
FROM order_items o1
JOIN order_items o2
  ON o1.order_id = o2.order_id AND o2.product <> o1.product
WHERE o1.product = '라면'
GROUP BY o2.product
ORDER BY together_cnt DESC, recommended;

-- 연습 문제
-- 1) '우유'를 산 주문에서 함께 가장 많이 담긴 상품 1개를 구하세요.
-- 2) 3개 상품이 모두 함께 담긴 조합(삼중 조합)을 셀프 조인 두 번으로 찾아 보세요.
