-- Day 23: 조건부 집계와 피벗 (SUM(CASE WHEN ...))
-- 목표: 집계 함수 안에 CASE WHEN 을 넣어 조건별 합계·개수를 한 번에 구하고, 행을 열로 펼치는 피벗 표를 만든다.

-- 개념 설명
-- 조건부 집계: SUM(CASE WHEN 조건 THEN 값 ELSE 0 END) 처럼 집계 함수 안에서 조건을 걸어 "조건에 맞는 행만" 집계한다.
-- 조건부 개수: SUM(CASE WHEN 조건 THEN 1 ELSE 0 END) 로 조건에 맞는 행의 개수를 센다.
--   (COUNT(CASE WHEN 조건 THEN 1 END) 도 같은 결과 - ELSE 가 없으면 NULL 이 되어 COUNT 에서 제외된다.)
-- 피벗(Pivot): GROUP BY 로 세로로 나오던 결과를, 조건부 집계로 가로 열(월별, 상태별 등)로 펼치는 기법.
-- WHERE 로 거르면 한 가지 조건만 볼 수 있지만, 조건부 집계는 여러 조건의 결과를 한 쿼리에서 나란히 볼 수 있다.
-- 이 파일은 SQLite·MySQL 공통 문법만 사용한다.

DROP TABLE IF EXISTS sales;

CREATE TABLE sales (
    id       INTEGER PRIMARY KEY,
    category VARCHAR(20) NOT NULL,
    quarter  INTEGER NOT NULL,      -- 분기 (1~4)
    status   VARCHAR(10) NOT NULL,  -- '완료' 또는 '취소'
    amount   INTEGER NOT NULL
);

INSERT INTO sales (id, category, quarter, status, amount) VALUES
    (1, '전자', 1, '완료', 100000),
    (2, '전자', 1, '취소',  30000),
    (3, '전자', 2, '완료', 150000),
    (4, '의류', 1, '완료',  50000),
    (5, '의류', 2, '완료',  70000),
    (6, '의류', 2, '취소',  20000),
    (7, '식품', 1, '완료',  40000),
    (8, '식품', 3, '완료',  60000),
    (9, '식품', 3, '취소',  10000);

-- 1) 기본 GROUP BY: 카테고리별 전체 합계 (취소 포함)
SELECT category, SUM(amount) AS total
FROM sales
GROUP BY category;
-- 결과: 식품 110000, 의류 140000, 전자 280000

-- 2) 조건부 집계: 카테고리별로 완료/취소 금액을 나란히 보기
SELECT category,
       SUM(CASE WHEN status = '완료' THEN amount ELSE 0 END) AS done_amount,
       SUM(CASE WHEN status = '취소' THEN amount ELSE 0 END) AS cancel_amount
FROM sales
GROUP BY category;
-- 결과: 식품 100000/10000, 의류 120000/20000, 전자 250000/30000

-- 3) 조건부 개수: 카테고리별 전체 건수와 취소 건수
SELECT category,
       COUNT(*) AS total_cnt,
       SUM(CASE WHEN status = '취소' THEN 1 ELSE 0 END) AS cancel_cnt
FROM sales
GROUP BY category;
-- 결과: 식품 3/1, 의류 3/1, 전자 3/1

-- 4) 피벗: 카테고리(행) x 분기(열) 완료 매출 표
SELECT category,
       SUM(CASE WHEN quarter = 1 THEN amount ELSE 0 END) AS q1,
       SUM(CASE WHEN quarter = 2 THEN amount ELSE 0 END) AS q2,
       SUM(CASE WHEN quarter = 3 THEN amount ELSE 0 END) AS q3,
       SUM(CASE WHEN quarter = 4 THEN amount ELSE 0 END) AS q4
FROM sales
WHERE status = '완료'
GROUP BY category;
-- 결과: 식품 40000/0/60000/0, 의류 50000/70000/0/0, 전자 100000/150000/0/0

-- 5) 비율 계산: 카테고리별 취소율(%) - 정수 나눗셈을 피하려고 100.0 을 곱한다
SELECT category,
       ROUND(100.0 * SUM(CASE WHEN status = '취소' THEN 1 ELSE 0 END) / COUNT(*), 1) AS cancel_rate
FROM sales
GROUP BY category;
-- 결과: 세 카테고리 모두 33.3

-- 6) HAVING 과 함께: 취소 금액이 20000 이상인 카테고리만
SELECT category,
       SUM(CASE WHEN status = '취소' THEN amount ELSE 0 END) AS cancel_amount
FROM sales
GROUP BY category
HAVING SUM(CASE WHEN status = '취소' THEN amount ELSE 0 END) >= 20000;
-- 결과: 의류 20000, 전자 30000

-- 연습 문제
-- 문제 1) 분기(quarter)별로 '완료' 건수와 '취소' 건수를 한 줄씩 보여 주세요.
-- 문제 2) 전체 매출 중 '완료' 금액이 차지하는 비율(%)을 카테고리별로 구해 보세요.
