-- Day 14: 윈도우 함수
-- 목표: 행을 합치지 않고 "행마다 순위·누적·이전 값"을 계산하는 윈도우 함수의 기본을 익힌다.

-- 개념 설명
-- 윈도우 함수는 함수() OVER (PARTITION BY 그룹 ORDER BY 정렬) 형태로 쓴다.
-- GROUP BY와 달리 결과 행이 줄어들지 않고, 각 행 옆에 계산 결과가 붙는다.
-- PARTITION BY : 그룹을 나눈다 (생략하면 전체가 한 그룹). ORDER BY : 그룹 안의 정렬 기준.
-- 순위 함수     : ROW_NUMBER() 연속 번호, RANK() 동점 시 같은 순위 후 건너뜀, DENSE_RANK() 동점 후 건너뛰지 않음
-- 집계 함수도 OVER와 함께 쓸 수 있다: SUM(amount) OVER (ORDER BY ...) 는 누적합이 된다.
-- 이전/다음 값  : LAG(컬럼) 바로 앞 행 값, LEAD(컬럼) 바로 뒤 행 값
-- 윈도우 함수는 SQLite 3.25 이상, MySQL 8.0 이상에서 사용할 수 있다.
-- 윈도우 함수 결과는 WHERE에 직접 쓸 수 없으므로, 서브쿼리로 감싼 뒤 바깥에서 조건을 건다.

DROP TABLE IF EXISTS sales;

CREATE TABLE sales (
    id         INTEGER PRIMARY KEY,
    dept       VARCHAR(20) NOT NULL,
    employee   VARCHAR(30) NOT NULL,
    amount     INTEGER NOT NULL,
    sale_month VARCHAR(7) NOT NULL
);

INSERT INTO sales (id, dept, employee, amount, sale_month) VALUES
    (1, '영업1팀', '김하늘', 500, '2026-01'),
    (2, '영업1팀', '이바다', 700, '2026-01'),
    (3, '영업1팀', '박나무', 700, '2026-02'),
    (4, '영업2팀', '최구름', 300, '2026-01'),
    (5, '영업2팀', '정햇살', 900, '2026-02'),
    (6, '영업2팀', '한노을', 600, '2026-03'),
    (7, '영업1팀', '김하늘', 800, '2026-03');

-- 1) ROW_NUMBER: 전체를 금액 높은 순으로 번호 매기기
SELECT employee, amount,
       ROW_NUMBER() OVER (ORDER BY amount DESC) AS rn
FROM sales;

-- 2) RANK와 DENSE_RANK 비교: 동점(700)일 때 순위가 어떻게 달라지는지 확인
SELECT employee, amount,
       RANK()       OVER (ORDER BY amount DESC) AS rnk,
       DENSE_RANK() OVER (ORDER BY amount DESC) AS dense_rnk
FROM sales;

-- 3) PARTITION BY: 팀별로 나누어 팀 안에서의 순위 구하기
SELECT dept, employee, amount,
       RANK() OVER (PARTITION BY dept ORDER BY amount DESC) AS dept_rank
FROM sales;

-- 4) 팀별 상위 1건만 뽑기: 윈도우 함수 결과는 서브쿼리로 감싸서 필터링한다
SELECT dept, employee, amount
FROM (
    SELECT dept, employee, amount,
           ROW_NUMBER() OVER (PARTITION BY dept ORDER BY amount DESC) AS rn
    FROM sales
) AS t
WHERE rn = 1;

-- 5) 누적합: 월 순서대로 매출을 누적 (같은 달 행은 id 순으로 정렬해 결과를 고정)
SELECT sale_month, amount,
       SUM(amount) OVER (ORDER BY sale_month, id) AS running_total
FROM sales
ORDER BY sale_month, id;

-- 6) 팀 합계를 각 행 옆에 붙이기: 행이 줄어들지 않는 점이 GROUP BY와 다르다
SELECT dept, employee, amount,
       SUM(amount) OVER (PARTITION BY dept) AS dept_total
FROM sales;

-- 7) LAG / LEAD: 이전·다음 행 값 (첫 행의 LAG, 마지막 행의 LEAD는 NULL)
SELECT sale_month, amount,
       LAG(amount)  OVER (ORDER BY sale_month, id) AS prev_amount,
       LEAD(amount) OVER (ORDER BY sale_month, id) AS next_amount
FROM sales
ORDER BY sale_month, id;

-- 연습 문제
-- 1) 각 팀(dept) 안에서 금액이 높은 순으로 DENSE_RANK를 매기고, 팀별 2위 이내 행만 조회해 보세요.
-- 2) 전체 매출을 월 순서(sale_month, id)대로 정렬하고, 이전 행 대비 금액 증감(amount - LAG(amount))을 구해 보세요.
