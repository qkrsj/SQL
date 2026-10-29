-- Day 16: 뷰(VIEW)
-- 목표: 자주 쓰는 SELECT 쿼리를 뷰로 저장해 테이블처럼 재사용하는 방법을 익힌다.

-- 개념 설명
-- 뷰는 SELECT 쿼리에 이름을 붙여 저장해 둔 "가상의 테이블"이다.
-- 데이터를 따로 복사해 두지 않고, 뷰를 조회할 때마다 원본 테이블에서 쿼리가 실행된다.
-- 만드는 법 : CREATE VIEW 뷰이름 AS SELECT ...;
-- 사용하는 법: 테이블처럼 SELECT * FROM 뷰이름 WHERE ...; 로 조회한다.
-- 장점      : 복잡한 JOIN/집계 쿼리를 단순하게 재사용할 수 있고,
--             보여주고 싶은 컬럼만 노출해 민감한 정보를 숨길 수 있다.
-- 주의      : 원본 테이블의 데이터가 바뀌면 뷰의 결과도 함께 바뀐다.
-- 삭제할 때 : DROP VIEW 뷰이름; (원본 테이블은 영향을 받지 않는다)
-- 이 파일은 SQLite·MySQL 공통 문법만 사용한다. (DROP VIEW IF EXISTS는 둘 다 지원)

DROP VIEW IF EXISTS dept_summary;
DROP VIEW IF EXISTS public_employees;
DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    id     INTEGER PRIMARY KEY,
    name   VARCHAR(30) NOT NULL,
    dept   VARCHAR(20) NOT NULL,
    salary INTEGER NOT NULL
);

INSERT INTO employees (id, name, dept, salary) VALUES
    (1, '김하늘', '개발',   5000),
    (2, '이바다', '개발',   4200),
    (3, '박나무', '디자인', 3800),
    (4, '최구름', '개발',   6100),
    (5, '정햇살', '디자인', 4100),
    (6, '한노을', '기획',   3900);

-- 1) 단순한 뷰: 급여(salary)를 숨기고 이름과 부서만 공개한다
CREATE VIEW public_employees AS
SELECT id, name, dept
FROM employees;

-- 2) 뷰는 테이블처럼 조회한다
SELECT * FROM public_employees WHERE dept = '개발';

-- 3) 집계 쿼리를 뷰로 저장: 부서별 인원수와 평균 급여
CREATE VIEW dept_summary AS
SELECT dept, COUNT(*) AS cnt, AVG(salary) AS avg_salary
FROM employees
GROUP BY dept;

SELECT * FROM dept_summary ORDER BY avg_salary DESC;

-- 4) 뷰를 다른 테이블과 JOIN하거나 조건을 더 걸 수도 있다
SELECT e.name, e.salary, s.avg_salary
FROM employees e
INNER JOIN dept_summary s ON e.dept = s.dept
WHERE e.salary > s.avg_salary;

-- 5) 원본 데이터가 바뀌면 뷰의 결과도 바뀐다
UPDATE employees SET salary = 7000 WHERE id = 2;
SELECT * FROM dept_summary ORDER BY dept;

-- 6) 정리: 뷰를 먼저 지우고, 테이블을 지운다
DROP VIEW dept_summary;
DROP VIEW public_employees;
DROP TABLE employees;

-- 연습 문제
-- 1) 아래 테이블 products(id, name, price, stock)에서 재고(stock)가 1 이상인 상품의 name, price만 보여주는
--    뷰 in_stock_products를 만들고, 그 뷰에서 가격이 1000 이상인 상품을 조회해 보세요.
-- 2) products에서 가격이 가장 높은 상품 하나의 name만 보여주는 뷰 top_product를 만들어 보세요.
--    (힌트: 서브쿼리 또는 ORDER BY price DESC LIMIT 1)
--
-- CREATE TABLE products (id INTEGER PRIMARY KEY, name VARCHAR(30), price INTEGER, stock INTEGER);
-- INSERT INTO products VALUES (1,'연필',500,100),(2,'노트',1500,0),(3,'가방',32000,5),(4,'지우개',700,50);
