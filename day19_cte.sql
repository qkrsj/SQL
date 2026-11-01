-- Day 19: CTE (WITH 절)
-- 목표: WITH 절로 복잡한 쿼리를 이름 붙은 단계로 나누어 읽기 쉽게 작성하는 방법을 익힌다.

-- 개념 설명
-- CTE(Common Table Expression)는 쿼리 맨 앞에 WITH 이름 AS (SELECT ...) 형태로 정의하는 "임시 결과 집합"이다.
-- 서브쿼리를 FROM 절 안에 중첩하는 대신, 위에서 아래로 단계별로 읽을 수 있게 해 준다.
-- 규칙: CTE 는 그 CTE 가 붙은 하나의 SELECT 문 안에서만 쓸 수 있다 (테이블이 새로 생기지는 않는다).
--       쉼표(,)로 여러 CTE 를 이어서 정의할 수 있고, 뒤쪽 CTE 는 앞쪽 CTE 를 참조할 수 있다.
-- 이 파일은 SQLite·MySQL(8.0 이상) 공통 문법만 사용한다.

DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    id   INTEGER PRIMARY KEY,
    name VARCHAR(30) NOT NULL
);

CREATE TABLE employees (
    id      INTEGER PRIMARY KEY,
    name    VARCHAR(30) NOT NULL,
    dept_id INTEGER NOT NULL,
    salary  INTEGER NOT NULL
);

INSERT INTO departments (id, name) VALUES
    (1, '개발'),
    (2, '영업'),
    (3, '인사');

INSERT INTO employees (id, name, dept_id, salary) VALUES
    (1, '김하늘', 1, 5000),
    (2, '이바다', 1, 4200),
    (3, '박나무', 2, 3800),
    (4, '최구름', 2, 3500),
    (5, '정노을', 3, 3000);

-- 1) 기본 CTE: 연봉이 4000 이상인 직원만 먼저 골라 이름을 붙이고, 그 결과를 조회한다
WITH high_paid AS (
    SELECT name, dept_id, salary
    FROM employees
    WHERE salary >= 4000
)
SELECT name, salary
FROM high_paid
ORDER BY salary DESC;                  -- 김하늘 5000, 이바다 4200

-- 2) CTE 로 집계한 뒤 JOIN: 부서별 평균 연봉을 구해 부서 이름과 연결한다
WITH dept_avg AS (
    SELECT dept_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY dept_id
)
SELECT d.name AS dept_name, a.avg_salary
FROM dept_avg AS a
INNER JOIN departments AS d ON d.id = a.dept_id
ORDER BY a.avg_salary DESC;            -- 개발 4600, 영업 3650, 인사 3000

-- 3) 여러 CTE 연결: 부서 평균(dept_avg)을 만들고, 그 평균보다 연봉이 높은 직원을 찾는다
WITH dept_avg AS (
    SELECT dept_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY dept_id
),
above_avg AS (
    SELECT e.name, e.dept_id, e.salary, a.avg_salary
    FROM employees AS e
    INNER JOIN dept_avg AS a ON a.dept_id = e.dept_id
    WHERE e.salary > a.avg_salary
)
SELECT name, salary, avg_salary
FROM above_avg
ORDER BY salary DESC;                  -- 김하늘 5000, 박나무 3800

-- 4) 같은 CTE 를 한 쿼리에서 두 번 사용: 전체 평균 연봉보다 높은 부서만 조회한다
WITH dept_avg AS (
    SELECT dept_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY dept_id
)
SELECT dept_id, avg_salary
FROM dept_avg
WHERE avg_salary > (SELECT AVG(avg_salary) FROM dept_avg);   -- 개발 (4600)

-- 연습 문제
-- 1) CTE 를 사용해 부서별 직원 수를 구한 뒤, 직원이 2명 이상인 부서의 이름과 직원 수를 조회해 보자.
-- 2) 예제 3번을 CTE 없이 FROM 절 서브쿼리로 다시 작성해 보고, 어느 쪽이 읽기 쉬운지 비교해 보자.
