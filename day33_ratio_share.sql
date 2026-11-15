-- Day 33: 비율과 점유율 계산 (전체 대비 %, 누적 비율)
-- 목표: 각 행이 전체(또는 그룹)에서 차지하는 비중을 구하고, 누적 비율로 상위 몇 %가 매출 대부분을 차지하는지 확인한다.

-- 개념 설명
--   점유율(%)    : 개별 값 / 전체 합계 * 100
--   전체 합계    : SUM(col) OVER ()                      -> 모든 행에 전체 합계를 붙여 준다.
--   그룹 내 합계 : SUM(col) OVER (PARTITION BY 그룹)     -> 그룹별 합계를 각 행에 붙여 준다.
--   누적 비율    : SUM(col) OVER (ORDER BY col DESC ...) / 전체 합계
--                  (큰 값부터 더해 가면 "상위 N개가 전체의 몇 %" 인지 알 수 있다. 파레토 분석)
-- 주의: 정수끼리 나누면 소수점이 버려진다. 100.0 을 곱해서 실수로 바꾼 뒤 ROUND 로 자리수를 맞춘다.
--       SUM() OVER () 는 SQLite 3.25+, MySQL 8.0+ 에서 사용 가능하다.

DROP TABLE IF EXISTS product_sales;

CREATE TABLE product_sales (
    id       INTEGER PRIMARY KEY,
    category VARCHAR(10) NOT NULL,
    product  VARCHAR(20) NOT NULL,
    amount   INTEGER     NOT NULL
);

INSERT INTO product_sales (id, category, product, amount) VALUES
    (1, '음료', '아메리카노', 500),
    (2, '음료', '라떼',       300),
    (3, '음료', '녹차',       100),
    (4, '빵',   '크루아상',   400),
    (5, '빵',   '식빵',       200),
    (6, '디저트', '케이크',   150),
    (7, '디저트', '마카롱',    50),
    (8, '디저트', '쿠키',     100);

-- 1) 제품별 전체 대비 점유율(%) : 합계 1800
SELECT product,
       amount,
       ROUND(amount * 100.0 / SUM(amount) OVER (), 1) AS share_pct
FROM product_sales
ORDER BY amount DESC;

-- 2) 카테고리 안에서의 점유율(%) : PARTITION BY 로 그룹 합계를 사용
SELECT category,
       product,
       amount,
       ROUND(amount * 100.0 / SUM(amount) OVER (PARTITION BY category), 1) AS share_in_category
FROM product_sales
ORDER BY category, amount DESC;

-- 3) 카테고리별 점유율 : GROUP BY 후 윈도우 함수를 한 번 더 적용
SELECT category,
       SUM(amount) AS category_total,
       ROUND(SUM(amount) * 100.0 / SUM(SUM(amount)) OVER (), 1) AS share_pct
FROM product_sales
GROUP BY category
ORDER BY category_total DESC;

-- 4) 누적 비율 (파레토) : 큰 매출부터 더해 가며 누적 %를 구한다.
--    id 를 함께 정렬 기준에 넣어 금액이 같은 행의 순서를 고정한다.
SELECT product,
       amount,
       SUM(amount) OVER (ORDER BY amount DESC, id
                         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
       ROUND(SUM(amount) OVER (ORDER BY amount DESC, id
                               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
             * 100.0 / SUM(amount) OVER (), 1) AS cumulative_pct
FROM product_sales
ORDER BY amount DESC, id;

-- 5) 누적 비율 80% 이내에 드는 핵심 제품만 추리기 (서브쿼리 사용)
SELECT product, amount, cumulative_pct
FROM (
    SELECT product,
           amount,
           ROUND(SUM(amount) OVER (ORDER BY amount DESC, id
                                   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
                 * 100.0 / SUM(amount) OVER (), 1) AS cumulative_pct
    FROM product_sales
) AS t
WHERE cumulative_pct <= 80
ORDER BY amount DESC;

-- 연습 문제
-- 1) 각 제품이 카테고리 최고 매출 제품 대비 몇 %인지 구해 보세요. (힌트: MAX(amount) OVER (PARTITION BY category))
-- 2) 5번 쿼리에서 "누적 80%를 처음 넘기는 제품"까지 포함하도록 바꿔 보세요.
--    (힌트: 이전 행까지의 누적 비율이 80 미만인 행만 남긴다)
