-- Day 34: 전월 대비 증감률 (LAG, NULLIF, 누적 합계)
-- 목표: 월별 매출에서 이전 달과 비교한 증감액·증감률(%)을 구하고, 0으로 나누는 오류를 피하는 방법을 익힌다.

-- 개념 설명
--   이전 행 값      : LAG(col, 1) OVER (ORDER BY month)   -> 바로 앞 행의 값 (첫 행은 NULL)
--   다음 행 값      : LEAD(col, 1) OVER (ORDER BY month)  -> 바로 뒤 행의 값
--   증감액          : 현재 값 - 이전 값
--   증감률(%)       : (현재 값 - 이전 값) * 100.0 / 이전 값
--   0 나누기 방지   : 분모를 NULLIF(이전 값, 0) 으로 감싸면 0 대신 NULL 이 되어 오류 없이 NULL 이 반환된다.
--   기본값 지정     : LAG(col, 1, 0) 처럼 세 번째 인자로 첫 행의 기본값을 정할 수 있다. (MySQL, SQLite 3.25+)
-- 주의: 정수끼리 나누면 소수점이 버려지므로 100.0 을 곱해 실수로 바꾼다.
--       월 데이터가 빠져 있으면 LAG 는 "바로 앞 행"을 가져오므로 달력상 이전 달과 다를 수 있다.

DROP TABLE IF EXISTS monthly_sales;

CREATE TABLE monthly_sales (
    month  CHAR(7) PRIMARY KEY,   -- 'YYYY-MM' 형식
    amount INTEGER NOT NULL
);

INSERT INTO monthly_sales (month, amount) VALUES
    ('2026-01', 1000),
    ('2026-02', 1200),
    ('2026-03', 900),
    ('2026-04', 900),
    ('2026-05', 1350),
    ('2026-06', 0),
    ('2026-07', 800),
    ('2026-08', 1600);

-- 1) 이전 달 매출 붙이기 (첫 달은 NULL)
SELECT month,
       amount,
       LAG(amount) OVER (ORDER BY month) AS prev_amount
FROM monthly_sales
ORDER BY month;

-- 2) 전월 대비 증감액
SELECT month,
       amount,
       amount - LAG(amount) OVER (ORDER BY month) AS diff
FROM monthly_sales
ORDER BY month;

-- 3) 전월 대비 증감률(%) : 6월 매출이 0 이므로 7월은 NULLIF 덕분에 NULL 이 된다.
SELECT month,
       amount,
       LAG(amount) OVER (ORDER BY month) AS prev_amount,
       ROUND((amount - LAG(amount) OVER (ORDER BY month)) * 100.0
             / NULLIF(LAG(amount) OVER (ORDER BY month), 0), 1) AS growth_pct
FROM monthly_sales
ORDER BY month;

-- 4) 증가/감소/유지 라벨 붙이기 : 계산을 서브쿼리에서 한 번만 하고 CASE WHEN 으로 분류
SELECT month,
       amount,
       diff,
       CASE
           WHEN diff IS NULL THEN '기준월'
           WHEN diff > 0     THEN '증가'
           WHEN diff < 0     THEN '감소'
           ELSE '유지'
       END AS trend
FROM (
    SELECT month,
           amount,
           amount - LAG(amount) OVER (ORDER BY month) AS diff
    FROM monthly_sales
) AS t
ORDER BY month;

-- 5) 첫 달 대비 지수(첫 달 = 100) : FIRST_VALUE 로 기준값을 가져온다.
SELECT month,
       amount,
       ROUND(amount * 100.0 / FIRST_VALUE(amount) OVER (ORDER BY month), 1) AS index_100
FROM monthly_sales
ORDER BY month;

-- 6) 직전 달보다 20% 넘게 증가한 달만 찾기
SELECT month, amount, growth_pct
FROM (
    SELECT month,
           amount,
           (amount - LAG(amount) OVER (ORDER BY month)) * 100.0
               / NULLIF(LAG(amount) OVER (ORDER BY month), 0) AS growth_pct
    FROM monthly_sales
) AS t
WHERE growth_pct > 20
ORDER BY month;

-- 연습 문제
-- 1) LEAD 를 사용해 "다음 달 매출"과 "다음 달 대비 증감액"을 함께 출력해 보세요.
-- 2) 2개월 전(LAG(amount, 2)) 대비 증감률(%)을 구해 보세요. 처음 2개월은 NULL 이어야 합니다.
