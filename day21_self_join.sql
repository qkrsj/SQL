-- Day 21: 셀프 조인 (SELF JOIN)
-- 목표: 같은 테이블을 두 번 사용하는 셀프 조인으로 계층 관계(직원-상사)와 같은 테이블 내 비교를 해결한다.

-- 개념 설명
-- 셀프 조인은 하나의 테이블을 별칭(alias)만 다르게 붙여 자기 자신과 JOIN 하는 방법이다.
-- 예) employees e (직원 역할), employees m (상사 역할) 로 나누어 e.manager_id = m.id 로 연결한다.
-- 상사가 없는 최상위 직원도 보려면 LEFT JOIN 을 사용한다. (INNER JOIN 은 상사가 없는 행이 사라진다)
-- 같은 테이블 안에서 행끼리 비교할 때도 쓴다. (예: 같은 부서에서 나보다 연봉이 높은 사람)
-- 별칭이 필수이며, 같은 쌍이 중복되지 않도록 a.id < b.id 조건을 자주 사용한다.
-- 이 파일은 SQLite·MySQL 공통 문법만 사용한다.

DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    id         INTEGER PRIMARY KEY,
    name       VARCHAR(30) NOT NULL,
    dept       VARCHAR(20) NOT NULL,
    salary     INTEGER NOT NULL,
    manager_id INTEGER            -- 상사의 id (최상위는 NULL)
);

INSERT INTO employees (id, name, dept, salary, manager_id) VALUES
    (1, '김대표', '경영', 9000, NULL),
    (2, '이부장', '개발', 7000, 1),
    (3, '박과장', '개발', 5500, 2),
    (4, '최대리', '개발', 4200, 3),
    (5, '정부장', '영업', 6800, 1),
    (6, '한대리', '영업', 4000, 5);

-- 1) 직원과 직속 상사 이름 함께 보기 (상사가 없는 대표는 제외됨)
SELECT e.name AS 직원, m.name AS 상사
FROM employees e
INNER JOIN employees m ON e.manager_id = m.id;
-- 결과: 이부장-김대표, 박과장-이부장, 최대리-박과장, 정부장-김대표, 한대리-정부장

-- 2) LEFT JOIN 으로 상사가 없는 직원도 포함 (상사 칸은 NULL)
SELECT e.name AS 직원, m.name AS 상사
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;
-- 김대표의 상사는 NULL

-- 3) 상사 이름이 없으면 '최상위'로 표시 (Day 20 COALESCE 활용)
SELECT e.name AS 직원, COALESCE(m.name, '최상위') AS 상사
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;

-- 4) 부하 직원이 몇 명인지 세기 (상사 기준으로 묶기)
SELECT m.name AS 상사, COUNT(e.id) AS 부하수
FROM employees m
LEFT JOIN employees e ON e.manager_id = m.id
GROUP BY m.id, m.name;
-- 김대표 2, 이부장 1, 박과장 1, 정부장 1, 최대리 0, 한대리 0

-- 5) 자기 상사보다 연봉이 높은 직원 찾기 (이 데이터에서는 없음)
SELECT e.name, e.salary, m.name AS 상사, m.salary AS 상사연봉
FROM employees e
INNER JOIN employees m ON e.manager_id = m.id
WHERE e.salary > m.salary;

-- 6) 같은 부서 직원끼리 짝 만들기 (a.id < b.id 로 중복 쌍 제거)
SELECT a.dept, a.name AS 직원1, b.name AS 직원2
FROM employees a
INNER JOIN employees b ON a.dept = b.dept AND a.id < b.id
ORDER BY a.dept, a.id, b.id;
-- 개발 3쌍(이부장-박과장, 이부장-최대리, 박과장-최대리), 영업 1쌍(정부장-한대리)

-- 연습 문제
-- 문제 1) 직원 이름, 상사 이름, 상사의 부서를 함께 조회하되 상사가 없는 직원도 포함하세요.
-- 문제 2) 같은 부서에서 나보다 연봉이 낮은 동료가 한 명이라도 있는 직원의 이름을 중복 없이 조회하세요.
