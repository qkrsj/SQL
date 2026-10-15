-- Day 3: ORDER BY, LIMIT
-- 목표: 조회 결과를 정렬(ORDER BY)하고, 원하는 개수만 가져오기(LIMIT, OFFSET)

-- 개념 설명
-- ORDER BY 컬럼 [ASC | DESC]: 결과를 정렬한다. 생략하면 ASC(오름차순)가 기본이다.
-- 여러 컬럼을 쉼표로 나열하면 앞의 컬럼이 같을 때 다음 컬럼으로 정렬한다.
-- LIMIT n: 결과의 처음 n개 행만 반환한다. OFFSET m을 붙이면 m개를 건너뛴 뒤 가져온다.
-- 절의 순서: SELECT -> FROM -> WHERE -> ORDER BY -> LIMIT
-- 주의: ORDER BY 없이 LIMIT을 쓰면 어떤 행이 나올지 보장되지 않는다.
-- NULL의 정렬 위치는 DB마다 다르다. (SQLite·MySQL은 ASC일 때 NULL이 맨 앞)

-- 준비: 테이블 생성 및 데이터 삽입
CREATE TABLE employees (
    id     INTEGER PRIMARY KEY,
    name   TEXT NOT NULL,
    dept   TEXT,
    salary INTEGER
);

INSERT INTO employees (id, name, dept, salary) VALUES
    (1, '김민수', 'IT',  4200),
    (2, '이서연', 'HR',  3800),
    (3, '박지훈', 'IT',  4600),
    (4, '최유나', '재무', 4000),
    (5, '김하늘', 'HR',  3500),
    (6, '정우진', NULL,  3900);

-- 1) 오름차순 정렬: 급여가 낮은 순
SELECT name, salary FROM employees ORDER BY salary ASC;

-- 2) 내림차순 정렬: 급여가 높은 순
SELECT name, salary FROM employees ORDER BY salary DESC;

-- 3) 다중 정렬: 부서 오름차순, 같은 부서 안에서는 급여 내림차순
SELECT name, dept, salary FROM employees ORDER BY dept ASC, salary DESC;

-- 4) WHERE와 함께: 급여 3800 이상인 직원을 이름순으로
SELECT name, salary FROM employees WHERE salary >= 3800 ORDER BY name;

-- 5) LIMIT: 급여 상위 3명
SELECT name, salary FROM employees ORDER BY salary DESC LIMIT 3;

-- 6) LIMIT + OFFSET: 급여 순위 4~5위 (3명 건너뛰고 2명)
SELECT name, salary FROM employees ORDER BY salary DESC LIMIT 2 OFFSET 3;

-- 연습 문제
-- 문제 1) 급여가 가장 낮은 직원 2명의 이름과 급여를 조회하세요.
-- 문제 2) 부서가 NULL이 아닌 직원을 부서 오름차순, 급여 내림차순으로 정렬해 조회하세요.

-- 정답 예시
-- SELECT name, salary FROM employees ORDER BY salary ASC LIMIT 2;
-- SELECT name, dept, salary FROM employees WHERE dept IS NOT NULL ORDER BY dept ASC, salary DESC;
