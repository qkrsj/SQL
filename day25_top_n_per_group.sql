-- Day 25: 그룹별 Top N 뽑기 (ROW_NUMBER, RANK, 상관 서브쿼리)
-- 목표: "부서별 연봉 상위 2명"처럼 그룹마다 상위 N개 행만 뽑는 패턴을 익힌다.

-- 개념 설명
-- LIMIT 는 전체 결과에서 N개만 자르므로 "그룹마다" N개를 뽑을 수는 없다.
-- 방법 1) 윈도우 함수: ROW_NUMBER() OVER (PARTITION BY 그룹 ORDER BY 기준 DESC) 로 그룹별 순번을 매기고,
--         바깥 쿼리(또는 CTE)에서 순번 <= N 인 행만 남긴다.
-- 방법 2) 상관 서브쿼리: "나보다 기준값이 큰 행이 N개 미만"인 행만 남긴다.
-- ROW_NUMBER 는 동점이어도 순번이 다르고, RANK 는 동점이면 같은 순위를 준다.
-- 윈도우 함수는 SQLite 3.25 이상, MySQL 8.0 이상에서 사용할 수 있다.

DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    id     INTEGER PRIMARY KEY,
    name   VARCHAR(20) NOT NULL,
    dept   VARCHAR(20) NOT NULL,
    salary INTEGER NOT NULL
);

INSERT INTO employees (id, name, dept, salary) VALUES
    (1, '김민수', '개발', 5500),
    (2, '이지은', '개발', 6200),
    (3, '박서준', '개발', 4800),
    (4, '최유나', '개발', 6200),
    (5, '정하늘', '영업', 4200),
    (6, '한가람', '영업', 4900),
    (7, '오세훈', '영업', 3900),
    (8, '윤서아', '인사', 4500),
    (9, '장도현', '인사', 4100);

-- 1) 전체 연봉 상위 3명 (그룹 없이는 LIMIT 로 충분하다)
SELECT name, dept, salary
FROM employees
ORDER BY salary DESC, id
LIMIT 3;
-- 결과: 이지은 6200, 최유나 6200, 김민수 5500

-- 2) 부서별 순번 매기기: ROW_NUMBER
SELECT name, dept, salary,
       ROW_NUMBER() OVER (PARTITION BY dept ORDER BY salary DESC, id) AS rn
FROM employees;
-- 결과: 부서마다 1부터 다시 시작하는 순번이 붙는다

-- 3) 부서별 연봉 상위 2명 (ROW_NUMBER + 서브쿼리)
SELECT dept, name, salary, rn
FROM (
    SELECT name, dept, salary,
           ROW_NUMBER() OVER (PARTITION BY dept ORDER BY salary DESC, id) AS rn
    FROM employees
) AS t
WHERE rn <= 2
ORDER BY dept, rn;
-- 결과: 개발 2명(이지은, 최유나), 영업 2명(한가람, 정하늘), 인사 2명(윤서아, 장도현)

-- 4) 동점을 함께 포함하고 싶다면 RANK: 부서별 연봉 1위(동점이면 모두)
SELECT dept, name, salary
FROM (
    SELECT name, dept, salary,
           RANK() OVER (PARTITION BY dept ORDER BY salary DESC) AS rnk
    FROM employees
) AS t
WHERE rnk = 1
ORDER BY dept, name;
-- 결과: 개발은 이지은·최유나(6200) 둘 다 나온다

-- 5) 윈도우 함수 없이: 상관 서브쿼리로 부서별 연봉 1위 (동점 포함)
SELECT e.dept, e.name, e.salary
FROM employees e
WHERE (SELECT COUNT(*)
       FROM employees x
       WHERE x.dept = e.dept AND x.salary > e.salary) < 1
ORDER BY e.dept, e.name;
-- 결과: 4번과 같다. "나보다 높은 사람이 0명"이면 1위다.

-- 6) 부서별 상위 2명의 연봉 합계 (Top N 결과를 다시 집계)
SELECT dept, SUM(salary) AS top2_total
FROM (
    SELECT dept, salary,
           ROW_NUMBER() OVER (PARTITION BY dept ORDER BY salary DESC, id) AS rn
    FROM employees
) AS t
WHERE rn <= 2
GROUP BY dept
ORDER BY dept;
-- 결과: 개발 12400, 영업 9100, 인사 8600

-- 연습 문제
-- 1) 부서별로 연봉이 가장 낮은 직원 1명씩을 조회하세요. (ROW_NUMBER 사용)
-- 2) 부서별 연봉 상위 3명을 조회하되, 동점자는 모두 포함하도록 RANK 로 바꿔 보세요.
