-- Day 1: SELECT 기초
-- 목표: 테이블 만들기, 데이터 넣기, SELECT로 조회하기

-- 1) 테이블 생성
CREATE TABLE employees (
    id     INTEGER PRIMARY KEY,
    name   TEXT NOT NULL,
    dept   TEXT,
    salary INTEGER
);

-- 2) 데이터 삽입
INSERT INTO employees (id, name, dept, salary) VALUES
    (1, '김민수', 'IT',  4200),
    (2, '이서연', 'HR',  3800),
    (3, '박지훈', 'IT',  4600),
    (4, '최유나', '재무', 4000);

-- 3) 전체 조회
SELECT * FROM employees;

-- 4) 원하는 컬럼만 조회
SELECT name, dept FROM employees;

-- 5) 별칭(AS) 사용
SELECT name AS 이름, salary AS 급여 FROM employees;

-- 6) 중복 제거(DISTINCT)
SELECT DISTINCT dept FROM employees;

-- 연습: salary 컬럼만 조회해 보세요.
