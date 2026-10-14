-- Day 2: WHERE 조건
-- 목표: WHERE 절로 원하는 행만 골라 조회하기 (비교, AND/OR/NOT, IN, BETWEEN, LIKE, IS NULL)

-- 개념 설명
-- WHERE는 FROM 뒤에 붙여 조건에 맞는 행만 걸러낸다.
-- 비교 연산자: =, <>(또는 !=), <, <=, >, >=
-- 논리 연산자: AND, OR, NOT (AND가 OR보다 먼저 계산되므로 괄호로 우선순위를 명확히 하자)
-- IN (목록), BETWEEN a AND b (양 끝 포함), LIKE 패턴 (% 는 여러 글자, _ 는 한 글자)
-- NULL은 = 로 비교할 수 없고 IS NULL / IS NOT NULL 을 써야 한다.

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

-- 1) 기본 비교: IT 부서 직원
SELECT * FROM employees WHERE dept = 'IT';

-- 2) 숫자 비교: 급여가 4000 이상
SELECT name, salary FROM employees WHERE salary >= 4000;

-- 3) AND: IT 부서이면서 급여가 4500 초과
SELECT name, salary FROM employees WHERE dept = 'IT' AND salary > 4500;

-- 4) OR: HR 또는 재무 부서 (괄호로 묶어 의도를 분명히)
SELECT name, dept FROM employees WHERE (dept = 'HR' OR dept = '재무');

-- 5) IN: 4)와 같은 결과를 더 간단하게
SELECT name, dept FROM employees WHERE dept IN ('HR', '재무');

-- 6) NOT: IT 부서가 아닌 직원 (dept가 NULL인 행은 결과에 포함되지 않음에 주의)
SELECT name, dept FROM employees WHERE NOT dept = 'IT';

-- 7) BETWEEN: 급여 3800 ~ 4200 (양 끝 포함)
SELECT name, salary FROM employees WHERE salary BETWEEN 3800 AND 4200;

-- 8) LIKE: 성이 '김'으로 시작하는 직원
SELECT name FROM employees WHERE name LIKE '김%';

-- 9) IS NULL: 부서가 아직 정해지지 않은 직원
SELECT name FROM employees WHERE dept IS NULL;

-- 연습 문제
-- 1. 급여가 3800 미만인 직원의 이름과 급여를 조회해 보세요.
-- 2. 부서가 IT 또는 HR이면서 이름이 '이'로 시작하는 직원을 조회해 보세요.
