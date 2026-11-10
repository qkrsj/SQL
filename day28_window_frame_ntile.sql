-- Day 28: 윈도우 함수 심화 (프레임, 이동 평균, NTILE, FIRST_VALUE)
-- 목표: 윈도우 프레임(ROWS BETWEEN)으로 이동 평균을 구하고, NTILE로 등급을 나누며, 그룹 내 첫 값/마지막 값과 비교한다.

-- 개념 설명
-- Day 14에서는 OVER (PARTITION BY ... ORDER BY ...) 의 기본을 배웠다.
-- 이번에는 "계산에 포함할 행의 범위"인 프레임(frame)을 직접 지정한다.
--   ROWS BETWEEN 2 PRECEDING AND CURRENT ROW  : 현재 행 + 앞의 2행 (총 3행)
--   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW : 처음부터 현재 행까지 (누적)
--   ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING  : 앞 1행, 현재, 뒤 1행
-- 주의: ORDER BY 만 쓰고 프레임을 생략하면 기본값이 "처음부터 현재 행까지"가 된다.
-- NTILE(n)      : 정렬된 행을 n개의 구간(등급)으로 최대한 균등하게 나눈다.
-- FIRST_VALUE() : 프레임의 첫 값,  LAST_VALUE() : 프레임의 마지막 값.
--   LAST_VALUE 는 기본 프레임 때문에 "현재 행"이 나오기 쉬우므로 프레임을 명시해야 한다.

DROP TABLE IF EXISTS daily_sales;

CREATE TABLE daily_sales (
    sale_date DATE        NOT NULL,
    branch    VARCHAR(10) NOT NULL,
    amount    INTEGER     NOT NULL
);

INSERT INTO daily_sales (sale_date, branch, amount) VALUES
    ('2026-11-01', '강남', 100),
    ('2026-11-02', '강남', 140),
    ('2026-11-03', '강남', 90),
    ('2026-11-04', '강남', 200),
    ('2026-11-05', '강남', 160),
    ('2026-11-01', '홍대', 50),
    ('2026-11-02', '홍대', 70),
    ('2026-11-03', '홍대', 60),
    ('2026-11-04', '홍대', 120);

-- 1) 3일 이동 평균 (오늘 + 앞의 2일), 지점별로 따로 계산
SELECT sale_date, branch, amount,
       ROUND(AVG(amount) OVER (
           PARTITION BY branch
           ORDER BY sale_date
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ), 1) AS moving_avg_3
FROM daily_sales
ORDER BY branch, sale_date;

-- 2) 지점별 누적 매출 (처음부터 현재 행까지)
SELECT sale_date, branch, amount,
       SUM(amount) OVER (
           PARTITION BY branch
           ORDER BY sale_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_total
FROM daily_sales
ORDER BY branch, sale_date;

-- 3) 앞뒤 하루를 포함한 3일 구간 평균 (가운데 정렬 이동 평균)
SELECT sale_date, amount,
       ROUND(AVG(amount) OVER (
           ORDER BY sale_date
           ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
       ), 1) AS centered_avg
FROM daily_sales
WHERE branch = '강남'
ORDER BY sale_date;

-- 4) NTILE: 매출 순으로 전체를 3등급으로 나누기 (1이 가장 높은 등급)
SELECT sale_date, branch, amount,
       NTILE(3) OVER (ORDER BY amount DESC) AS grade
FROM daily_sales
ORDER BY amount DESC;

-- 5) 지점별 첫날 매출, 마지막 날 매출과 비교하기
--    LAST_VALUE 는 프레임을 끝까지(UNBOUNDED FOLLOWING) 늘려야 진짜 마지막 값이 나온다.
SELECT sale_date, branch, amount,
       FIRST_VALUE(amount) OVER (
           PARTITION BY branch ORDER BY sale_date
       ) AS first_amount,
       LAST_VALUE(amount) OVER (
           PARTITION BY branch ORDER BY sale_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS last_amount,
       amount - FIRST_VALUE(amount) OVER (
           PARTITION BY branch ORDER BY sale_date
       ) AS diff_from_first
FROM daily_sales
ORDER BY branch, sale_date;

-- 연습 문제
-- 문제 1) 강남 지점의 매출을 "직전 2일 + 오늘"이 아니라 "오늘 + 뒤의 1일" 합계로 구해 보세요. (힌트: ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING)
-- 문제 2) 모든 지점의 매출을 NTILE(2)로 상위/하위 그룹으로 나눈 뒤, 그룹별 평균 매출을 구해 보세요. (힌트: NTILE 결과를 CTE로 만든 뒤 GROUP BY)
